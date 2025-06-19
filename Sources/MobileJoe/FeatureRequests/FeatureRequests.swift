//
//  File.swift
//  MobileJoe
//
//  Created by Florian Mielke on 08.05.25.
//

import Foundation

@MainActor
@Observable
public class FeatureRequests {
  public var all: [FeatureRequest] = []
  public var sorting: Sorting = .byNewest {
    didSet {
      applySorting(all)
    }
  }

  private let gateway: FeatureRequestGateway

  public init(gateway: FeatureRequestGateway? = nil) {
    self.gateway = gateway ?? RemoteFeatureRequestGateway.shared
  }

  public func load() async throws {
    let featureRequests = try await gateway.load()
    applySorting(featureRequests)
  }

  public func vote(_ featureRequest: FeatureRequest) async throws {
    try await gateway.vote(featureRequest)
    let all = try await gateway.all()
    applySorting(all)
  }

  private func applySorting(_ featureRequests: [FeatureRequest]) {
    all = sorting.sorted(featureRequests)
  }
}

extension FeatureRequests {
  public enum Sorting: CaseIterable, Identifiable {
    case byNewest
    case byScore

    public var id: Self { self }

    func sorted(_ featureRequest: [FeatureRequest]) -> [FeatureRequest] {
      switch self {
      case .byNewest: sortByNewest(featureRequest)
      case .byScore: sortByScore(featureRequest)
      }
    }

    private func sortByScore(_ featureRequests: [FeatureRequest]) -> [FeatureRequest] {
      featureRequests.sorted { lhs, rhs in
        if lhs.score == rhs.score {
          return lhs.id < rhs.id
        }
        return lhs.score > rhs.score
      }
    }

    private func sortByNewest(_ featureRequests: [FeatureRequest]) -> [FeatureRequest] {
      featureRequests.sorted { lhs, rhs in
        if lhs.createdAt == rhs.createdAt {
          return lhs.id < rhs.id
        }
        return lhs.createdAt > rhs.createdAt
      }
    }
  }
}

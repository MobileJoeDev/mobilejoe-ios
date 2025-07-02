//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequests.swift
//
//  Created by Florian Mielke on 08.05.25.
//

import Foundation

@MainActor
@Observable
public class FeatureRequests {
  public var all: [FeatureRequest] {
    gateway.all
      .sorted(by: sorting)
      .filtered(by: filtering)
  }

  public var sorting: Sorting = .byNewest
  public var filtering: Filter = .all

  public var isEmpty: Bool {
    all.isEmpty
  }

  private let gateway: FeatureRequestGateway

  public init(gateway: FeatureRequestGateway? = nil) {
    self.gateway = gateway ?? RemoteFeatureRequestGateway.shared
  }

  public func load() async throws {
    _ = try await gateway.load(filteredBy: nil)
  }

  public func vote(_ featureRequest: FeatureRequest) async throws {
    try await gateway.vote(featureRequest)
  }
}

// MARK: - Sorting
extension FeatureRequests {
  public enum Sorting: CaseIterable, Identifiable {
    case byNewest
    case byScore

    public var id: Self { self }
  }
}

fileprivate extension Array where Element == FeatureRequest {
  func sorted(by sorting: FeatureRequests.Sorting) -> [Element] {
    switch sorting {
    case .byNewest: sortByNewest()
    case .byScore: sortByScore()
    }
  }

  private func sortByScore() -> [Element] {
    sorted { lhs, rhs in
      if lhs.score == rhs.score {
        return lhs.id < rhs.id
      }
      return lhs.score > rhs.score
    }
  }

  private func sortByNewest() -> [Element] {
    sorted { lhs, rhs in
      if lhs.createdAt == rhs.createdAt {
        return lhs.id < rhs.id
      }
      return lhs.createdAt > rhs.createdAt
    }
  }
}

extension FeatureRequests {
  public enum Filter: CaseIterable, Identifiable {
    case all
    case underReview
    case planned
    case inProgress
    case completed

    public var id: Self { self }

    var toStatus: FeatureRequest.Status? {
      switch self {
      case .all: nil
      case .underReview: .underReview
      case .planned: .planned
      case .inProgress: .inProgress
      case .completed: .completed
      }
    }
  }
}

fileprivate extension Array where Element == FeatureRequest {
  func filtered(by filter: FeatureRequests.Filter) -> [Element] {
    guard let status = filter.toStatus else { return self }
    return self.filter { $0.status == status }
  }
}

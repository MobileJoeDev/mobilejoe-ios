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
  public var all = [FeatureRequest]()

  public var sorting: FeatureRequest.Sorting = .byNewest {
    didSet {
      Task {
        try? await reload()
      }
    }
  }

  public var filtering: Filter = .all {
    didSet {
      Task {
        try? await reload()
      }
    }
  }

  public var isEmpty: Bool {
    all.isEmpty
  }

  private let gateway: FeatureRequestGateway

  public init(gateway: FeatureRequestGateway? = nil) {
    self.gateway = gateway ?? RemoteFeatureRequestGateway.shared
  }

  public func load() async throws {
    try await gateway.load(filterBy: filtering.toStatus, sort: sorting)
    all = gateway.featureRequests
  }

  public func reload() async throws {
    try await gateway.reload(filterBy: filtering.toStatus, sort: sorting)
    all = gateway.featureRequests
  }

  public func vote(_ featureRequest: FeatureRequest) async throws {
    try await gateway.vote(featureRequest)
    all = gateway.featureRequests
  }
}

// MARK: - Filtering
extension FeatureRequests {
  public enum Filter: CaseIterable, Identifiable {
    case all
    case underReview
    case planned
    case inProgress
    case completed

    public var id: Self { self }

    var toStatus: [FeatureRequest.Status] {
      switch self {
      case .all: [.open, .underReview, .planned, .inProgress, .completed]
      case .underReview: [.underReview]
      case .planned: [.planned]
      case .inProgress: [.inProgress]
      case .completed: [.completed]
      }
    }
  }
}

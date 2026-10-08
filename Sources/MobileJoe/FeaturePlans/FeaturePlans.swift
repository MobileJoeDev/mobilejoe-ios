// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoeResources
import Observation

@Observable
public class FeaturePlans {
  public var all = [FeaturePlan]()

  public var sorting: FeaturePlan.Sorting = .byNewest {
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

  public func search(for searchText: String) async throws {
    guard searchText != search else { return }
    search = searchText
    debounceSearch()
  }

  private func debounceSearch() {
    searchDebounceTask?.cancel()
    searchDebounceTask = Task { [weak self] in
      do {
        try await Task.sleep(for: .seconds(0.35))
        guard !Task.isCancelled, let self else { return }
        try? await reload()
      } catch {
      }
    }
  }

  public var isEmpty: Bool {
    all.isEmpty
  }

  private var search: String = ""
  private(set) var searchDebounceTask: Task<Void, Never>? = nil
  private let gateway: FeaturePlanGateway

  public init(gateway: FeaturePlanGateway? = nil) {
    self.gateway = gateway ?? RemoteFeaturePlanGateway.shared
  }

  @MainActor deinit {
    searchDebounceTask?.cancel()
  }

  public func load() async throws {
    try await gateway.load(filterBy: filtering.toStatus, sort: sorting, search: search)
    all = gateway.featurePlans
  }

  public func reload() async throws {
    try await gateway.reload(filterBy: filtering.toStatus, sort: sorting, search: search)
    all = gateway.featurePlans
  }

  public func vote(_ featurePlan: FeaturePlan) async throws {
    try await gateway.vote(featurePlan)
    all = gateway.featurePlans
  }

  public func featurePlan(id: Int) async throws -> FeaturePlan {
    do {
      return try await gateway.featurePlan(id: id)
    } catch FeaturePlanGatewayError.unknownFeaturePlan {
      throw FeaturePlansError.unknownFeaturePlan
    }
  }
}

// MARK: - Filtering
extension FeaturePlans {
  public enum Filter: CaseIterable, Identifiable {
    case all
    case underReview
    case planned
    case inProgress
    case completed
    case roadmap

    public var id: Self { self }

    var toStatus: [FeaturePlan.Status] {
      switch self {
      case .all: [.open, .underReview, .planned, .inProgress]
      case .underReview: [.underReview]
      case .planned: [.planned]
      case .inProgress: [.inProgress]
      case .completed: [.completed]
      case .roadmap: [.underReview, .planned, .inProgress]
      }
    }
  }
}

// MARK: - Error

public enum FeaturePlansError: LocalizedError {
  case unknownFeaturePlan

  public var errorDescription: String? {
    switch self {
    case .unknownFeaturePlan: String(localized: "feature-plans.error.unknown-feature-plan.description", bundle: Resources.bundle)
    }
  }
}

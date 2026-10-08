// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
@testable import MobileJoe

class FeaturePlanGatewayMock: FeaturePlanGateway {
  private var container = [FeaturePlan]()

  var allReturnValue: [FeaturePlan] = []
  var featurePlans: [FeaturePlan] {
    container
  }

  // Tracking properties for tests
  var lastSearch: String?
  var lastSorting: FeaturePlan.Sorting?
  var lastStatuses: [FeaturePlan.Status]?
  var reloadCallCount = 0
  var loadCallCount = 0
  var voteCallCount = 0

  func load(filterBy statuses: [FeaturePlan.Status]?, sort: FeaturePlan.Sorting, search: String?) async throws {
    loadCallCount += 1
    lastSearch = search
    lastSorting = sort
    lastStatuses = statuses

    container = allReturnValue
      .filter { featurePlan in
        guard let statuses else { return true }
        return statuses.contains(featurePlan.status)
      }
  }

  func reload(filterBy statuses: [FeaturePlan.Status]?, sort: FeaturePlan.Sorting, search: String?) async throws {
    reloadCallCount += 1
    lastSearch = search
    lastSorting = sort
    lastStatuses = statuses

    container = allReturnValue
      .filter { featurePlan in
        guard let statuses else { return true }
        return statuses.contains(featurePlan.status)
      }
  }

  var featurePlanCallCount = 0
  var featurePlanReturnValue: FeaturePlan?

  func featurePlan(id: Int) async throws -> FeaturePlan {
    featurePlanCallCount += 1
    guard let featurePlan = featurePlanReturnValue ?? allReturnValue.first(where: { $0.id == id }) else {
      throw FeaturePlanGatewayError.unknownFeaturePlan
    }
    return featurePlan
  }

  func vote(_ featurePlan: FeaturePlan) async throws {
    voteCallCount += 1
  }
}

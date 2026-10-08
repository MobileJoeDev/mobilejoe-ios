// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
@testable import MobileJoe

class APIClientMock: APIClient {
  enum Error: Swift.Error {
    case missingResult
  }

  var mockDebugMode = false
  var isDebugModeEnabled: Bool {
    mockDebugMode
  }

  var getAlertsCallCount = 0
  var mockGetAlertsError: Swift.Error?
  var mockGetAlerts: Data?
  func getAlerts() async throws -> Data {
    getAlertsCallCount += 1

    if let mockGetAlertsError {
      throw mockGetAlertsError
    }

    guard let mockGetAlerts else {
      throw Error.missingResult
    }
    return mockGetAlerts
  }

  var getFAQsCallCount = 0
  var mockGetFAQsError: Swift.Error?
  var mockGetFAQs: Data?
  func getFAQs() async throws -> Data {
    getFAQsCallCount += 1

    if let mockGetFAQsError {
      throw mockGetFAQsError
    }

    guard let mockGetFAQs else {
      throw Error.missingResult
    }
    return mockGetFAQs
  }

  func getFeaturePlans(filterBy statuses: [MobileJoe.FeaturePlan.Status]?, sort sorting: MobileJoe.FeaturePlan.Sorting, search: String?, page: Int) async throws -> (
    data: Data,
    pagination: MobileJoe.Pagination
  ) {
    throw Error.missingResult
  }

  func getFeaturePlan(id: Int) async throws -> Data {
    throw Error.missingResult
  }

  func postFeaturePlanVote(featurePlanID: Int) async throws -> Data {
    throw Error.missingResult
  }
}

//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  NetworkClientMock.swift
//
//  Created by Florian Mielke on 17.10.25.
//

import Foundation
@testable import MobileJoe

class APIClientMock: APIClient {
  enum Error: Swift.Error {
    case missingResult
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

  func getFeatureRequests(filterBy statuses: [MobileJoe.FeatureRequest.Status]?, sort sorting: MobileJoe.FeatureRequest.Sorting, search: String?, page: Int) async throws -> (
    data: Data,
    pagination: MobileJoe.Pagination
  ) {
    throw Error.missingResult
  }

  func postVoteFeatureRequests(featureRequestID: Int) async throws -> Data {
    throw Error.missingResult
  }

  func postIdentify() async throws {
  }
}

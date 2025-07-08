//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestGatewayMock.swift
//
//  Created by Florian Mielke on 02.07.25.
//

import Foundation
@testable import MobileJoe

class FeatureRequestGatewayMock: FeatureRequestGateway {
  private var container = [FeatureRequest]()

  var allReturnValue: [FeatureRequest] = []
  var featureRequests: [FeatureRequest] {
    container
  }

  func load(filterBy statuses: [FeatureRequest.Status]?, sort: FeatureRequest.Sorting) async throws {
    container = allReturnValue
      .filter { fr in
        guard let statuses else { return true }
        return statuses.contains(fr.status)
      }
  }

  func reload(filterBy statuses: [FeatureRequest.Status]?, sort: FeatureRequest.Sorting) async throws {
    container = allReturnValue
      .filter { fr in
        guard let statuses else { return true }
        return statuses.contains(fr.status)
      }
  }

  func vote(_ featureRequest: FeatureRequest) async throws {

  }
}

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
  var allReturnValue: [FeatureRequest]?
  var all: [FeatureRequest] {
    allReturnValue ?? []
  }

  func load(filteredBy status: FeatureRequest.Status?) async throws -> [FeatureRequest] {
    all
      .filter { fr in
        guard let status else { return true }
        return fr.status == status
      }
  }

  func vote(_ featureRequest: FeatureRequest) async throws {

  }
}

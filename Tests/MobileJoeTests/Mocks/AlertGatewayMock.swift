//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  AlertGatewayMock.swift
//
//  Created by Florian Mielke on 10.10.25.
//

import Foundation
@testable import MobileJoe

class AlertGatewayMock: AlertGateway {
  private var container = [Alert]()

  var allReturnValue: [Alert] = []
  var alerts: [Alert] {
    container
  }

  var loadCallCount = 0

  func load() async throws {
    loadCallCount += 1
    container = allReturnValue
  }
}

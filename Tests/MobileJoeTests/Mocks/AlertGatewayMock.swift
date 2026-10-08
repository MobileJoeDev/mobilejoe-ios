// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

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

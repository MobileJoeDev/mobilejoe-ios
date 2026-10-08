// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
@testable import MobileJoe

class FAQGatewayMock: FAQGateway {
  private var container = [FAQItem]()

  var allReturnValue: [FAQItem] = []
  var faqs: [FAQItem] {
    container
  }

  var loadCallCount = 0

  func load() async throws {
    loadCallCount += 1
    container = allReturnValue
  }
}

// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Observation

@Observable
public class FAQs {
  public package(set) var all = [FAQItem]()

  public var isEmpty: Bool {
    all.isEmpty
  }

  private let gateway: FAQGateway

  public convenience init() {
    self.init(gateway: RemoteFAQGateway.shared)
  }

  package init(gateway: FAQGateway) {
    self.gateway = gateway
  }

  public func load() async throws {
    try await gateway.load()
    all = gateway.faqs
  }
}

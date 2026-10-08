// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Observation

@Observable
public class FAQs {
  public var all = [FAQItem]()

  public var isEmpty: Bool {
    all.isEmpty
  }

  private let gateway: FAQGateway

  public init(gateway: FAQGateway? = nil) {
    self.gateway = gateway ?? RemoteFAQGateway.shared
  }

  public func load() async throws {
    try await gateway.load()
    all = gateway.faqs
  }
}

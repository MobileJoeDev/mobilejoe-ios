// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Observation

@Observable
public class Alerts {
  public package(set) var all = [Alert]()

  public var isEmpty: Bool {
    all.isEmpty
  }

  private let gateway: AlertGateway

  public convenience init() {
    self.init(gateway: RemoteAlertGateway.shared)
  }

  package init(gateway: AlertGateway) {
    self.gateway = gateway
  }

  public func load() async throws {
    try await gateway.load()
    all = gateway.alerts
  }
}

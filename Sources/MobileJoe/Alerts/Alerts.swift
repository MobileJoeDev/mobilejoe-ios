// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Observation

@Observable
public class Alerts {
  public var all = [Alert]()

  public var isEmpty: Bool {
    all.isEmpty
  }

  private let gateway: AlertGateway

  public init(gateway: AlertGateway? = nil) {
    self.gateway = gateway ?? RemoteAlertGateway.shared
  }

  public func load() async throws {
    try await gateway.load()
    all = gateway.alerts
  }
}

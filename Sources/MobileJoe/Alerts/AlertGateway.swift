// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

package protocol AlertGateway {
  var alerts: [Alert] { get }
  func load() async throws
}

enum AlertGatewayError: Error {
  case unknownAlert
}

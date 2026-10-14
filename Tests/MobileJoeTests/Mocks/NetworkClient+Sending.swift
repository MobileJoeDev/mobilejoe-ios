// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

@testable import MobileJoe

extension NetworkClient {
  func configureAndSend(withAPIKey apiKey: String, externalID: String?, debugMode: Bool = false) async throws {
    if let identity = try configure(withAPIKey: apiKey, externalID: externalID, debugMode: debugMode) {
      await send(identity)
    }
  }

  func identifyAndSend(externalID: String?) async throws {
    if let identity = try identify(externalID: externalID) {
      await send(identity)
    }
  }
}

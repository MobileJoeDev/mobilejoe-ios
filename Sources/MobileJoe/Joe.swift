// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

public class Joe {
  /// The current identity, or nil when no local identity is available.
  public static var identity: Identity? {
    IdentityManager.shared.currentIdentity
  }

  public static func configure(withAPIKey apiKey: String, appUserID: String? = nil, debugMode: Bool = false) async throws {
    try await NetworkClient.shared.configure(withAPIKey: apiKey, externalID: appUserID, debugMode: debugMode)
  }

  public static func identify(appUserID: String) async throws {
    try await NetworkClient.shared.identify(externalID: appUserID)
  }

  public static func logout() async throws {
    try await NetworkClient.shared.logout()
  }
}

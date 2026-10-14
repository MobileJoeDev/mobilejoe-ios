// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

public class Joe {
  /// The current identity, or nil when no local identity is available.
  public static var identity: Identity? {
    IdentityManager.shared.currentIdentity
  }

  public static func configure(withAPIKey apiKey: String, appUserID: String? = nil, debugMode: Bool = false) throws {
    guard let identity = try NetworkClient.shared.configure(withAPIKey: apiKey, externalID: appUserID, debugMode: debugMode) else { return }
    Task { await NetworkClient.shared.send(identity) }
  }

  public static func identify(appUserID: String) throws {
    guard let identity = try NetworkClient.shared.identify(externalID: appUserID) else { return }
    Task { await NetworkClient.shared.send(identity) }
  }

  public static func logout() throws {
    let identity = try NetworkClient.shared.logout()
    Task { await NetworkClient.shared.send(identity) }
  }
}

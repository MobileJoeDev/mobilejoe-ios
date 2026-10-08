// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

class IdentityManager {
  static let shared = IdentityManager()

  private(set) var currentIdentity: Identity?
  private let gateway: IdentityGateway
  private var isLogoutPending = false
  private var isCurrentIdentitySynchronized = false

  init(gateway: IdentityGateway = FileBasedIdentityGateway.shared, identity: Identity? = nil) {
    self.gateway = gateway
    self.currentIdentity = identity
  }

  func prepareIdentity(for externalID: String?) async throws -> Identity? {
    if isIdentified(by: externalID) { return nil }
    // A failed switch must not let a later return to the previous account skip synchronization.
    isCurrentIdentitySynchronized = false
    if isLogoutPending {
      _ = try await logout()
    }
    var identity = try await gateway.find() ?? Identity(externalID: externalID)
    guard let externalID else { return identity }
    if isSwitchingAccount(from: identity, to: externalID) {
      identity = try await logout()
    }
    identity.update(externalID: externalID)
    return identity
  }

  func commit(_ identity: Identity) async throws {
    if identity != (try await gateway.find()) {
      try await gateway.save(identity: identity)
    }
    currentIdentity = identity
    isCurrentIdentitySynchronized = true
  }

  func logout() async throws -> Identity {
    isCurrentIdentitySynchronized = false
    isLogoutPending = true
    currentIdentity = nil
    try await gateway.delete()
    let identity = Identity(externalID: nil)
    try await gateway.save(identity: identity)
    currentIdentity = identity
    isLogoutPending = false
    return identity
  }

  private func isIdentified(by externalID: String?) -> Bool {
    guard isCurrentIdentitySynchronized, let currentIdentity else { return false }
    guard let externalID else { return true }
    return currentIdentity.externalID == Identity.hashExternalID(from: externalID)
  }

  private func isSwitchingAccount(from identity: Identity, to externalID: String) -> Bool {
    guard let currentExternalID = identity.externalID else { return false }
    return currentExternalID != Identity.hashExternalID(from: externalID)
  }
}

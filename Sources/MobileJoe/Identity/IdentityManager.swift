// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

class IdentityManager {
  static let shared = IdentityManager()

  private enum State {
    /// No identity has been loaded or identified in this process yet.
    case unknown
    /// The identity is persisted and used for requests. Identifying it again sends no request.
    case identified(Identity)
    /// A logout failed partway. The next identify completes it before reusing any persisted identity.
    case loggingOut
  }

  private let gateway: IdentityGateway
  private var state: State

  init(gateway: IdentityGateway = FileBasedIdentityGateway.shared, identity: Identity? = nil) {
    self.gateway = gateway
    self.state = identity.map(State.identified) ?? .unknown
  }

  var currentIdentity: Identity? {
    switch state {
    case let .identified(identity): identity
    case .unknown, .loggingOut: nil
    }
  }

  func identifyAtStart(externalID: String?) throws -> Identity? {
    try identify(externalID: externalID) ?? currentIdentity
  }

  func identify(externalID: String?) throws -> Identity? {
    try validate(externalID: externalID)
    guard let identity = try prepareIdentity(for: externalID) else { return nil }
    try gateway.save(identity: identity)
    state = .identified(identity)
    return identity
  }

  func isCurrent(_ identity: Identity) -> Bool {
    currentIdentity == identity
  }

  func logout() throws -> Identity {
    state = .loggingOut
    try gateway.delete()
    let identity = Identity(externalID: nil)
    try gateway.save(identity: identity)
    state = .identified(identity)
    return identity
  }

  private func validate(externalID: String?) throws {
    if let externalID, externalID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      throw MobileJoeError.invalidAppUserID
    }
  }

  private func prepareIdentity(for externalID: String?) throws -> Identity? {
    if isIdentified(as: externalID) { return nil }
    try completePendingLogout()
    let identity = try findOrCreateIdentity(for: externalID)
    guard let externalID else { return identity }
    return try assign(externalID, to: identity)
  }

  private func isIdentified(as externalID: String?) -> Bool {
    guard let currentIdentity else { return false }
    guard let externalID else { return true }
    return currentIdentity.belongs(to: externalID)
  }

  private func completePendingLogout() throws {
    guard case .loggingOut = state else { return }
    _ = try logout()
  }

  private func findOrCreateIdentity(for externalID: String?) throws -> Identity {
    try gateway.find() ?? Identity(externalID: externalID)
  }

  private func assign(_ externalID: String, to identity: Identity) throws -> Identity {
    let belongsToOther = !identity.isAnonymous && !identity.belongs(to: externalID)
    var identity = belongsToOther ? try logout() : identity
    identity.update(externalID: externalID)
    return identity
  }
}

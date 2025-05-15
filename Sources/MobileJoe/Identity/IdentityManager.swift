//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 15.05.25.
//

import Foundation

@MainActor
class IdentityManager {
  static let shared = IdentityManager()

  private let gateway: IdentityGateway

  init(gateway: IdentityGateway = FileBasedIdentityGateway.shared) {
    self.gateway = gateway
  }

  func findOrCreate(with appUserID: String?) async throws -> Identity {
    if let identity = try await gateway.find() {
      return try await updateIfNeeded(identity, with: appUserID)
    } else {
      return try await createIdentity(with: appUserID)
    }
  }

  func updateIfNeeded(_ identity: Identity, with appUserID: String?) async throws -> Identity {
    guard appUserID != identity.externalID else { return identity }
    var editableIdentity = identity
    editableIdentity.update(externalID: appUserID)
    try await gateway.save(identity: editableIdentity)
    return editableIdentity
  }

  func reset() async throws {
    try await gateway.delete()
  }
}

extension IdentityManager {
  private func createIdentity(with appUserID: String?) async throws -> Identity {
    let identity = makeIdentity(appUserID: appUserID)
    try await gateway.save(identity: identity)
    return identity
  }

  private func makeIdentity(appUserID: String?) -> Identity {
    Identity(externalID: appUserID)
  }
}

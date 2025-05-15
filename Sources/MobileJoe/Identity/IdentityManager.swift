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
    editableIdentity.externalID = appUserID
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
    let anonymousID = generateAnonymousID()
    let externalID = generateExternalID(from: appUserID)
    return Identity(anonymousID: anonymousID, externalID: externalID)
  }

  private func generateExternalID(from appUserID: String?) -> String? {
    guard let appUserID else { return nil }
    return "$MBJExternalID:\(appUserID.cleaned.sha256Truncated(length: 32))"
  }

  private func generateAnonymousID() -> String {
    "$MBJAnonymousID:\(UUID().compactString)"
  }

  private static let anonymousRegex = #"\$MBJAnonymousID:([a-z0-9]{32})$"#
}

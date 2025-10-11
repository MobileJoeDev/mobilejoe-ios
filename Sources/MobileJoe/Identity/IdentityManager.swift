//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  IdentityManager.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import Foundation

class IdentityManager {
  static let shared = IdentityManager()

  private let gateway: IdentityGateway

  init(gateway: IdentityGateway = FileBasedIdentityGateway.shared) {
    self.gateway = gateway
  }

  func findOrCreate(by externalID: String?) async throws -> Identity {
    if let identity = try await gateway.find() {
      return try await updateIfNeeded(identity, with: externalID)
    } else {
      return try await createIdentity(with: externalID)
    }
  }

  func reset() async throws {
    try await gateway.delete()
  }
}

extension IdentityManager {
  private func updateIfNeeded(_ identity: Identity, with externalID: String?) async throws -> Identity {
    guard Identity.hashExternalID(from: externalID) != identity.externalID else { return identity }
    var editableIdentity = identity
    editableIdentity.update(externalID: externalID)
    try await gateway.save(identity: editableIdentity)
    return editableIdentity
  }

  private func createIdentity(with appUserID: String?) async throws -> Identity {
    let identity = makeIdentity(appUserID: appUserID)
    try await gateway.save(identity: identity)
    return identity
  }

  private func makeIdentity(appUserID: String?) -> Identity {
    Identity(externalID: appUserID)
  }
}

// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct IdentityLogoutPersistenceTests {
  @Test func failedLogoutDoesNotRestoreOldIDsAfterReopeningStorage() async throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    let gateway = FailingSaveGateway(directory: directory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let oldIdentity = Identity(externalID: "old-account")
    try await gateway.save(identity: oldIdentity)
    gateway.shouldFailSave = true

    await #expect(throws: CocoaError(.fileWriteNoPermission)) {
      try await IdentityManager(gateway: gateway, identity: oldIdentity).logout()
    }

    let reopenedGateway = FileBasedIdentityGateway(directory: directory)
    #expect(try await reopenedGateway.find() == nil)
    let reopenedManager = IdentityManager(gateway: reopenedGateway)
    let identity = try #require(await reopenedManager.prepareIdentity(for: "new-account"))
    try await reopenedManager.commit(identity)
    #expect(identity.anonymousID != oldIdentity.anonymousID)
    #expect(identity.deviceID != oldIdentity.deviceID)
    #expect(identity.externalID == Identity.hashExternalID(from: "new-account"))
  }

  @Test(arguments: [false, true])
  func logoutPersistsFreshIdentity(hasExistingIdentity: Bool) async throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    let gateway = FileBasedIdentityGateway(directory: directory)
    defer { try? FileManager.default.removeItem(at: directory) }

    let oldIdentity = Identity(externalID: "account-id")
    if hasExistingIdentity {
      try await gateway.save(identity: oldIdentity)
    }

    let identity = try await IdentityManager(gateway: gateway).logout()

    let reopenedGateway = FileBasedIdentityGateway(directory: directory)
    let persistedIdentity = try await reopenedGateway.find()
    #expect(persistedIdentity == identity)
    #expect(identity.anonymousID != oldIdentity.anonymousID)
    #expect(identity.deviceID != oldIdentity.deviceID)
    #expect(identity.externalID == nil)

    let reopenedManager = IdentityManager(gateway: reopenedGateway)
    let reusedIdentity = try #require(await reopenedManager.prepareIdentity(for: nil))
    try await reopenedManager.commit(reusedIdentity)
    #expect(reusedIdentity == identity)
  }
}

private class FailingSaveGateway: FileBasedIdentityGateway {
  var shouldFailSave = false

  override func save(identity: Identity) async throws {
    if shouldFailSave { throw CocoaError(.fileWriteNoPermission) }
    try await super.save(identity: identity)
  }
}

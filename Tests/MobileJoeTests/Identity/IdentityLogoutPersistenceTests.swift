// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct IdentityLogoutPersistenceTests {
  @Test func `failed logout does not restore old IDs after reopening storage`() throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    let gateway = FailingSaveGateway(directory: directory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let oldIdentity = Identity(externalID: "old-account")
    try gateway.save(identity: oldIdentity)
    gateway.shouldFailSave = true

    #expect(throws: CocoaError(.fileWriteNoPermission)) {
      try IdentityManager(gateway: gateway, identity: oldIdentity).logout()
    }

    let reopenedGateway = FileBasedIdentityGateway(directory: directory)
    #expect(try reopenedGateway.find() == nil)
    let reopenedManager = IdentityManager(gateway: reopenedGateway)
    let identity = try #require(try reopenedManager.identify(externalID: "new-account"))
    #expect(identity.anonymousID != oldIdentity.anonymousID)
    #expect(identity.deviceID != oldIdentity.deviceID)
    #expect(identity.externalID == Identity.hashExternalID(from: "new-account"))
  }

  @Test(arguments: [false, true])
  func `logout persists fresh identity`(hasExistingIdentity: Bool) throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    let gateway = FileBasedIdentityGateway(directory: directory)
    defer { try? FileManager.default.removeItem(at: directory) }

    let oldIdentity = Identity(externalID: "account-id")
    if hasExistingIdentity {
      try gateway.save(identity: oldIdentity)
    }

    let identity = try IdentityManager(gateway: gateway).logout()

    let reopenedGateway = FileBasedIdentityGateway(directory: directory)
    let persistedIdentity = try reopenedGateway.find()
    #expect(persistedIdentity == identity)
    #expect(identity.anonymousID != oldIdentity.anonymousID)
    #expect(identity.deviceID != oldIdentity.deviceID)
    #expect(identity.externalID == nil)

    let reopenedManager = IdentityManager(gateway: reopenedGateway)
    let reusedIdentity = try #require(try reopenedManager.identify(externalID: nil))
    #expect(reusedIdentity == identity)
  }
}

private class FailingSaveGateway: FileBasedIdentityGateway {
  var shouldFailSave = false

  override func save(identity: Identity) throws {
    if shouldFailSave { throw CocoaError(.fileWriteNoPermission) }
    try super.save(identity: identity)
  }
}

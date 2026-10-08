// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct IdentityManagerTests {
  let manager: IdentityManager
  let gatewayMock: IdentityGatewayMock

  init() {
    gatewayMock = IdentityGatewayMock()
    manager = IdentityManager(gateway: gatewayMock)
  }

  @Test func `find or create identity when none present`() async throws {
    let identity = try #require(await manager.prepareIdentity(for: nil))
    #expect(manager.currentIdentity == nil)
    #expect(gatewayMock.saveIdentityCalledWithIdentity == nil)
    try await manager.commit(identity)

    #expect(identity.externalID == nil)
    #expect(manager.currentIdentity == identity)
    #expect(gatewayMock.saveIdentityCalledWithIdentity == identity)
  }

  @Test func `find or create identity finds existing identity`() async throws {
    gatewayMock.findReturnValue = Identity(externalID: "external-id")

    let identity = try #require(await manager.prepareIdentity(for: "external-id"))
    try await manager.commit(identity)

    #expect(identity.externalID == Identity.hashExternalID(from: "external-id"))
    #expect(manager.currentIdentity == identity)
    #expect(gatewayMock.saveIdentityCalledWithIdentity == nil)
  }

  @Test func `switching account replaces existing identity with fresh IDs`() async throws {
    let existing = Identity(externalID: "external-id")
    gatewayMock.findReturnValue = existing

    let identity = try #require(await manager.prepareIdentity(for: "external-id-2"))
    try await manager.commit(identity)

    #expect(gatewayMock.deleteCalled)
    #expect(identity.anonymousID != existing.anonymousID)
    #expect(identity.deviceID != existing.deviceID)
    #expect(identity.externalID == Identity.hashExternalID(from: "external-id-2"))
    #expect(manager.currentIdentity == identity)
    #expect(gatewayMock.saveIdentityCalledWithIdentity == identity)
  }

  @Test func `failed switch persistence leaves pending logout for retry`() async throws {
    let existing = Identity(externalID: "external-id")
    gatewayMock.findReturnValue = existing
    gatewayMock.saveError = CocoaError(.fileWriteNoPermission)

    await #expect(throws: CocoaError(.fileWriteNoPermission)) {
      _ = try await manager.prepareIdentity(for: "external-id-2")
    }
    #expect(manager.currentIdentity == nil)
    #expect(gatewayMock.findReturnValue == nil)

    gatewayMock.saveError = nil
    let identity = try #require(await manager.prepareIdentity(for: "external-id-2"))
    #expect(identity.anonymousID != existing.anonymousID)
    #expect(identity.externalID == Identity.hashExternalID(from: "external-id-2"))
  }

  @Test func identificationAfterLogoutKeepsAnonymousIDs() async throws {
    let anonymousIdentity = try await manager.logout()
    let identity = try #require(await manager.prepareIdentity(for: "new-account"))
    try await manager.commit(identity)

    #expect(manager.currentIdentity == identity)
    #expect(identity.externalID == Identity.hashExternalID(from: "new-account"))
    #expect(identity.anonymousID == anonymousIdentity.anonymousID)
    #expect(identity.deviceID == anonymousIdentity.deviceID)
  }

  @Test func identifyAfterFailedLogoutCreatesFreshIDs() async throws {
    let oldIdentity = try #require(await manager.prepareIdentity(for: "old-account"))
    try await manager.commit(oldIdentity)
    gatewayMock.saveError = CocoaError(.fileWriteNoPermission)
    await #expect(throws: CocoaError(.fileWriteNoPermission)) {
      try await manager.logout()
    }
    #expect(manager.currentIdentity == nil)
    #expect(gatewayMock.findReturnValue == nil)

    gatewayMock.saveError = nil
    let identity = try #require(await manager.prepareIdentity(for: "new-account"))
    try await manager.commit(identity)
    #expect(identity.anonymousID != oldIdentity.anonymousID)
    #expect(identity.deviceID != oldIdentity.deviceID)
    #expect(identity.externalID == Identity.hashExternalID(from: "new-account"))
  }

  @Test func failedDeletionBlocksIdentificationUntilLogoutCanComplete() async throws {
    let oldIdentity = try #require(await manager.prepareIdentity(for: "old-account"))
    try await manager.commit(oldIdentity)
    gatewayMock.deleteError = CocoaError(.fileWriteNoPermission)
    await #expect(throws: CocoaError(.fileWriteNoPermission)) {
      try await manager.logout()
    }
    let reads = gatewayMock.findCallCount
    await #expect(throws: CocoaError(.fileWriteNoPermission)) {
      _ = try await manager.prepareIdentity(for: "new-account")
    }
    #expect(manager.currentIdentity == nil)
    #expect(gatewayMock.findReturnValue == oldIdentity)
    #expect(gatewayMock.findCallCount == reads)

    gatewayMock.deleteError = nil
    let identity = try #require(await manager.prepareIdentity(for: "new-account"))
    try await manager.commit(identity)
    #expect(identity.anonymousID != oldIdentity.anonymousID)
    #expect(identity.deviceID != oldIdentity.deviceID)
  }
}

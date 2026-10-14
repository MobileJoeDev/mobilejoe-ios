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

  @Test func `find or create identity when none present`() throws {
    let identity = try #require(try manager.identify(externalID: nil))

    #expect(identity.externalID == nil)
    #expect(manager.currentIdentity == identity)
    #expect(gatewayMock.saveIdentityCalledWithIdentity == identity)
  }

  @Test func `find or create identity finds existing identity`() throws {
    gatewayMock.findReturnValue = Identity(externalID: "external-id")

    let identity = try #require(try manager.identify(externalID: "external-id"))

    #expect(identity.externalID == Identity.hashExternalID(from: "external-id"))
    #expect(manager.currentIdentity == identity)
    #expect(gatewayMock.saveIdentityCalledWithIdentity == identity)
  }

  @Test func `identified identity is persisted and identifying it again changes nothing`() throws {
    let identity = try #require(try manager.identify(externalID: "external-id"))

    #expect(identity.externalID == Identity.hashExternalID(from: "external-id"))
    #expect(manager.currentIdentity == identity)
    #expect(gatewayMock.saveIdentityCalledWithIdentity == identity)

    #expect(try manager.identify(externalID: "external-id") == nil)
    #expect(manager.currentIdentity == identity)
  }

  @Test func `identifying at start returns the identity left by an earlier logout`() throws {
    let loggedOut = try manager.logout()

    #expect(try manager.identify(externalID: nil) == nil)
    #expect(try manager.identifyAtStart(externalID: nil) == loggedOut)
  }

  @Test func `switching app user ID replaces existing identity with fresh IDs`() throws {
    let existing = Identity(externalID: "external-id")
    gatewayMock.findReturnValue = existing

    let identity = try #require(try manager.identify(externalID: "external-id-2"))

    #expect(gatewayMock.deleteCalled)
    #expect(identity.anonymousID != existing.anonymousID)
    #expect(identity.deviceID != existing.deviceID)
    #expect(identity.externalID == Identity.hashExternalID(from: "external-id-2"))
    #expect(manager.currentIdentity == identity)
    #expect(gatewayMock.saveIdentityCalledWithIdentity == identity)
  }

  @Test func `failed switch persistence leaves pending logout for retry`() throws {
    let existing = Identity(externalID: "external-id")
    gatewayMock.findReturnValue = existing
    gatewayMock.saveError = CocoaError(.fileWriteNoPermission)

    #expect(throws: CocoaError(.fileWriteNoPermission)) {
      _ = try manager.identify(externalID: "external-id-2")
    }
    #expect(manager.currentIdentity == nil)
    #expect(gatewayMock.findReturnValue == nil)

    gatewayMock.saveError = nil
    let identity = try #require(try manager.identify(externalID: "external-id-2"))
    #expect(identity.anonymousID != existing.anonymousID)
    #expect(identity.externalID == Identity.hashExternalID(from: "external-id-2"))
  }

  @Test func `identification after logout keeps anonymous IDs`() throws {
    let anonymousIdentity = try manager.logout()
    let identity = try #require(try manager.identify(externalID: "new-account"))

    #expect(manager.currentIdentity == identity)
    #expect(identity.externalID == Identity.hashExternalID(from: "new-account"))
    #expect(identity.anonymousID == anonymousIdentity.anonymousID)
    #expect(identity.deviceID == anonymousIdentity.deviceID)
  }

  @Test func `identify after failed logout creates fresh IDs`() throws {
    let oldIdentity = try #require(try manager.identify(externalID: "old-account"))
    gatewayMock.saveError = CocoaError(.fileWriteNoPermission)
    #expect(throws: CocoaError(.fileWriteNoPermission)) {
      try manager.logout()
    }
    #expect(manager.currentIdentity == nil)
    #expect(gatewayMock.findReturnValue == nil)

    gatewayMock.saveError = nil
    let identity = try #require(try manager.identify(externalID: "new-account"))
    #expect(identity.anonymousID != oldIdentity.anonymousID)
    #expect(identity.deviceID != oldIdentity.deviceID)
    #expect(identity.externalID == Identity.hashExternalID(from: "new-account"))
  }

  @Test func `failed deletion blocks identification until logout can complete`() throws {
    let oldIdentity = try #require(try manager.identify(externalID: "old-account"))
    gatewayMock.deleteError = CocoaError(.fileWriteNoPermission)
    #expect(throws: CocoaError(.fileWriteNoPermission)) {
      try manager.logout()
    }
    let reads = gatewayMock.findCallCount
    #expect(throws: CocoaError(.fileWriteNoPermission)) {
      _ = try manager.identify(externalID: "new-account")
    }
    #expect(manager.currentIdentity == nil)
    #expect(gatewayMock.findReturnValue == oldIdentity)
    #expect(gatewayMock.findCallCount == reads)

    gatewayMock.deleteError = nil
    let identity = try #require(try manager.identify(externalID: "new-account"))
    #expect(identity.anonymousID != oldIdentity.anonymousID)
    #expect(identity.deviceID != oldIdentity.deviceID)
  }
}

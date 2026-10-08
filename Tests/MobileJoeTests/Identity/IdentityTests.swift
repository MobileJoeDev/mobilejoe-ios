// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Testing
import Foundation
@testable import MobileJoe

struct IdentityTests {
  @Test(arguments: [nil, "account-id"] as [String?])
  func `display only the current user ID`(externalID: String?) {
    let identity = Identity(externalID: externalID)
    let expectedID = identity.externalID ?? identity.anonymousID

    #expect(identity.id == expectedID)
    #expect("\(identity)" == expectedID)
    #expect(String(reflecting: identity) == expectedID)
    var output = ""
    print(identity, terminator: "", to: &output)
    #expect(output == expectedID)
    output = ""
    debugPrint(identity, terminator: "", to: &output)
    #expect(output == expectedID)
  }

  @Test func `preserve identity snapshot after logout`() async throws {
    let manager = IdentityManager(gateway: IdentityGatewayMock())
    let identified = try #require(await manager.prepareIdentity(for: "account-id"))
    try await manager.commit(identified)
    let snapshot = identified
    let anonymous = try await manager.logout()

    #expect(snapshot.id == identified.externalID)
    #expect(anonymous.id == anonymous.anonymousID)
    #expect(snapshot.id != anonymous.id)
  }

  @Test func `create identity with external ID`() throws {
    let identity = Identity(externalID: "external-id")

    #expect(isAnonymousID(identity.anonymousID))
    #expect(isExternalID(identity.externalID))
    #expect(isDeviceID(identity.deviceID))
  }

  @Test func `create identity without external ID`() throws {
    let identity = Identity(externalID: nil)

    #expect(identity.externalID == nil)
    #expect(isAnonymousID(identity.anonymousID))
    #expect(isDeviceID(identity.deviceID))
  }
}

extension IdentityTests {
  private func isAnonymousID(_ anonymousID: String) -> Bool {
    (try? Regex(Identity.anonymousIDPattern).wholeMatch(in: anonymousID)) != nil
  }

  private func isExternalID(_ externalID: String?) -> Bool {
    guard let externalID else { return false }
    return (try? Regex(Identity.externalIDPattern).wholeMatch(in: externalID)) != nil
  }

  private func isDeviceID(_ deviceID: String?) -> Bool {
    guard let deviceID else { return false }
    return (try? Regex(Identity.deviceIDPattern).wholeMatch(in: deviceID)) != nil
  }
}

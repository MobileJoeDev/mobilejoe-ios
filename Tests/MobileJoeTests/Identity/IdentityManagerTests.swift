//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  IdentityManagerTests.swift
//
//  Created by Florian Mielke on 20.06.25.
//

import Testing
@testable import MobileJoe

struct IdentityManagerTests {
  let manager: IdentityManager
  let gatewayMock: IdentityGatewayMock

  init() {
    gatewayMock = IdentityGatewayMock()
    manager = IdentityManager(gateway: gatewayMock)
  }

  @Test func findOrCreate_noIdentityPresent() async throws {
    let identity = try await manager.findOrCreate(by: nil)

    #expect(identity.externalID == nil)
    #expect(gatewayMock.saveIdentityCalledWithIdentity == identity)
  }

  @Test func findOrCreate_findsExistingIdentity() async throws {
    gatewayMock.findReturnValue = Identity(externalID: "external-id")

    let identity = try await manager.findOrCreate(by: "external-id")

    #expect(identity.externalID == Identity.generateExternalID(from: "external-id"))
    #expect(gatewayMock.saveIdentityCalledWithIdentity == nil)
  }

  @Test func findOrCreate_updatesExistingIdentity() async throws {
    gatewayMock.findReturnValue = Identity(externalID: "external-id")

    let identity = try await manager.findOrCreate(by: "external-id-2")

    #expect(identity.externalID == Identity.generateExternalID(from: "external-id-2"))
    #expect(gatewayMock.saveIdentityCalledWithIdentity == identity)
  }
}

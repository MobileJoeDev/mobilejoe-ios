//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  IdentityTests.swift
//
//  Created by Florian Mielke on 15.05.25.
//

import Testing
@testable import MobileJoe

struct IdentityTests {
  @Suite struct Creation {
    @Test func withExternalID() async throws {
      let identity = Identity(externalID: "my-external-id-1")

      let externalID = try #require(identity.externalID)
      #expect(externalID.hasPrefix("$MBJExternalID:"))
      #expect(identity.anonymousID.hasPrefix("$MBJAnonymousID:"))
    }

    @Test func withoutExternalID() async throws {
      let identity = Identity(externalID: nil)

      #expect(identity.externalID == nil)
      #expect(identity.anonymousID.hasPrefix("$MBJAnonymousID:"))
    }
  }
}

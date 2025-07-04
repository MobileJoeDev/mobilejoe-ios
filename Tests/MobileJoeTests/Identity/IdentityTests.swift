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
  @Test func create_withExternalID() throws {
    let identity = Identity(externalID: "external-id")

    #expect(isAnonymousID(identity.anonymousID))
    #expect(isExternalID(identity.externalID))
  }

  @Test func create_withoutExternalID() throws {
    let identity = Identity(externalID: nil)

    #expect(identity.externalID == nil)
    #expect(isAnonymousID(identity.anonymousID))
  }
}

extension IdentityTests {
  private func isAnonymousID(_ anonymousID: String) -> Bool {
    ((try? Regex(Identity.anonymousIDPattern).wholeMatch(in: anonymousID) != nil) != nil)
  }

  private func isExternalID(_ externalID: String?) -> Bool {
    guard let externalID else { return false }
    return ((try? Regex(Identity.externalIDPattern).wholeMatch(in: externalID) != nil) != nil)
  }
}

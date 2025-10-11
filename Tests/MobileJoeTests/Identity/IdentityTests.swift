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
import Foundation
@testable import MobileJoe

struct IdentityTests {
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

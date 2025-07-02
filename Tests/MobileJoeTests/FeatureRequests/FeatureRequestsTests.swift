//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestsTests.swift
//
//  Created by Florian on 02.07.25.
//

import Foundation
import Testing
@testable import MobileJoe

@MainActor
struct FeatureRequestsTests {
  let gateway: FeatureRequestGatewayMock
  let subject: FeatureRequests

  init() {
    gateway = FeatureRequestGatewayMock()
    subject = FeatureRequests(gateway: gateway)
  }

  @Test("Filter feature requests")
  func filterFeatureRequests() async throws {
    gateway.allReturnValue = fixtures
    try await subject.load()

    subject.filtering = .planned

    #expect(subject.all.count == 1)

    subject.filtering = .all

    #expect(subject.all.count == 2)
  }
}

extension FeatureRequestsTests {
  private var fixtures: [FeatureRequest] {
    [
      FeatureRequest(
        id: 1,
        title: "Import holidays from calendar",
        body: "Choose an iOS calendar to automatically import and sync holidays in WorkTimes.",
        score: 10,
        statusIdentifier: "open",
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 17, hour: 12)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 12)!,
        isVoted: true
      ),
      FeatureRequest(
        id: 2,
        title: "Cloud Sync",
        body: "Sync records and accounts via iCloud on multiple devices.",
        score: 33,
        statusIdentifier: "planned",
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 13)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 18, hour: 13)!,
        isVoted: false
      )
    ]
  }
}

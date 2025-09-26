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

struct FeatureRequestsTests {
  let gateway: FeatureRequestGatewayMock
  let subject: FeatureRequests

  init() {
    gateway = FeatureRequestGatewayMock()
    subject = FeatureRequests(gateway: gateway)
    gateway.allReturnValue = fixtures
  }

  /// Note to the usage of `Task.sleep` here. Setting a `filtering` calls the async `load()` function
  /// of the subject wrapped in a `Task` call. To wait for the `load()` function to be finished, we have to pause
  /// the executing to let the results bubble in.
  @Test("Filter feature requests")
  func filterFeatureRequests() async throws {
    try await subject.load()
    #expect(subject.all.count == 3)

    subject.filtering = .planned
    try await Task.sleep(nanoseconds: 1)

    let featureRequest = try #require(subject.all.first)
    #expect(featureRequest.status == .planned)
    #expect(subject.all.count == 1)

    subject.filtering = .all
    try await Task.sleep(nanoseconds: 1)

    #expect(subject.all.count == 3)
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
        statusIdentifier: FeatureRequest.Status.open.rawValue,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 17, hour: 12)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 12)!,
        isVoted: true
      ),
      FeatureRequest(
        id: 2,
        title: "Cloud Sync",
        body: "Sync records and accounts via iCloud on multiple devices.",
        score: 33,
        statusIdentifier: FeatureRequest.Status.planned.rawValue,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 13)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 18, hour: 13)!,
        isVoted: false
      ),
      FeatureRequest(
        id: 3,
        title: "Do not change the view date when changing the app",
        body: """
        I’m editing old time entries form 1 year ago. For that, sometimes I need to change to another app to get some information about that date. When I change back to the worktimes app, it automatically returns to the current date, so I have to scroll back manually to the date I was editing and hope that I did not forget the information in the meantime so that I would have to change back to the other app (infinite loop 🙂).
        
        As there is already a button to return to the current date, I don’t see much of a reason to change the shown date automatically when switching the app. My suggestion is to remove this “feature” or make it optional.
        """,
        score: 10,
        statusIdentifier: FeatureRequest.Status.inProgress.rawValue,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 11)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 16, hour: 11)!,
        isVoted: true
      )
    ]
  }
}

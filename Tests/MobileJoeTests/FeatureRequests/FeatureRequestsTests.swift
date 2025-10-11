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
//  Created by Florian Mielke on 02.07.25.
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

  @Test func `filter feature requests`() async throws {
    try await subject.load()
    #expect(subject.all.count == 3)

    // Instead of relying on the didSet side effect, explicitly reload with the new filter
    subject.filtering = .planned
    try await subject.reload()

    let featureRequest = try #require(subject.all.first)
    #expect(featureRequest.status == .planned)
    #expect(subject.all.count == 1)

    subject.filtering = .all
    try await subject.reload()

    #expect(subject.all.count == 3)
  }

  @Test func `sort feature requests by score`() async throws {
    try await subject.load()
    #expect(subject.all.count == 3)

    subject.sorting = .byScore
    try await subject.reload()

    #expect(subject.all.count == 3)
    #expect(gateway.lastSorting == .byScore)
  }

  @Test func `sort feature requests by newest`() async throws {
    try await subject.load()

    subject.sorting = .byNewest
    try await subject.reload()

    #expect(gateway.lastSorting == .byNewest)
  }

  @Test func `search triggers reload after debounce`() async throws {
    try await subject.load()
    #expect(subject.all.count == 3)

    try await subject.search(for: "Cloud")

    // Wait for debounce (0.35s) + buffer
    try await Task.sleep(for: .milliseconds(400))

    #expect(gateway.lastSearch == "Cloud")
    #expect(gateway.reloadCallCount >= 1)
  }

  @Test func `rapid search queries cancel previous searches`() async throws {
    try await subject.load()
    gateway.reloadCallCount = 0

    try await subject.search(for: "First")
    try await Task.sleep(for: .milliseconds(100))

    try await subject.search(for: "Second")
    try await Task.sleep(for: .milliseconds(100))

    try await subject.search(for: "Final")

    // Wait for debounce
    try await Task.sleep(for: .milliseconds(400))

    // Should only reload once with final search term
    #expect(gateway.lastSearch == "Final")
    #expect(gateway.reloadCallCount == 1)
  }

  @Test func `empty search string is handled`() async throws {
    try await subject.load()

    try await subject.search(for: "")
    try await Task.sleep(for: .milliseconds(400))

    #expect(gateway.lastSearch == "")
  }

  @Test func `duplicate search does not trigger reload`() async throws {
    try await subject.load()
    gateway.reloadCallCount = 0

    try await subject.search(for: "Cloud")
    try await Task.sleep(for: .milliseconds(400))

    let firstCallCount = gateway.reloadCallCount

    // Same search again
    try await subject.search(for: "Cloud")
    try await Task.sleep(for: .milliseconds(400))

    // Should not trigger another reload
    #expect(gateway.reloadCallCount == firstCallCount)
  }

  @Test func `vote updates local feature requests`() async throws {
    try await subject.load()
    let original = try #require(subject.all.first)

    try await subject.vote(original)

    #expect(gateway.voteCallCount == 1)
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
        status: .open,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 17, hour: 12)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 12)!,
        isVoted: true
      ),
      FeatureRequest(
        id: 2,
        title: "Cloud Sync",
        body: "Sync records and accounts via iCloud on multiple devices.",
        score: 33,
        status: .planned,
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
        status: .inProgress,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 11)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 16, hour: 11)!,
        isVoted: true
      )
    ]
  }
}

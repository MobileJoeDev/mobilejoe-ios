// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct FeaturePlansTests {
  let gateway: FeaturePlanGatewayMock
  let subject: FeaturePlans

  init() {
    gateway = FeaturePlanGatewayMock()
    subject = FeaturePlans(gateway: gateway)
    gateway.allReturnValue = fixtures
  }

  @Test func `filter feature plans`() async throws {
    try await subject.load()
    #expect(subject.all.count == 3)

    // Instead of relying on the didSet side effect, explicitly reload with the new filter
    subject.filtering = .planned
    try await subject.reload()

    let featurePlan = try #require(subject.all.first)
    #expect(featurePlan.status == .planned)
    #expect(subject.all.count == 1)

    subject.filtering = .all
    try await subject.reload()

    #expect(subject.all.count == 3)
  }

  @Test func `sort feature plans by score`() async throws {
    try await subject.load()
    #expect(subject.all.count == 3)

    subject.sorting = .byScore
    try await subject.reload()

    #expect(subject.all.count == 3)
    #expect(gateway.lastSorting == .byScore)
  }

  @Test func `sort feature plans by newest`() async throws {
    try await subject.load()

    subject.sorting = .byNewest
    try await subject.reload()

    #expect(gateway.lastSorting == .byNewest)
  }

  @Test func `search triggers reload after debounce`() async throws {
    try await subject.load()
    #expect(subject.all.count == 3)

    try await subject.search(for: "Cloud")
    await subject.searchDebounceTask?.value

    #expect(gateway.lastSearch == "Cloud")
    #expect(gateway.reloadCallCount == 1)
  }

  @Test func `rapid search queries cancel previous searches`() async throws {
    try await subject.load()
    gateway.reloadCallCount = 0

    try await subject.search(for: "First")
    try await subject.search(for: "Second")
    try await subject.search(for: "Final")
    await subject.searchDebounceTask?.value

    // Should only reload once with final search term
    #expect(gateway.lastSearch == "Final")
    #expect(gateway.reloadCallCount == 1)
  }

  @Test func `empty search string is handled`() async throws {
    try await subject.load()

    try await subject.search(for: "")

    #expect(subject.searchDebounceTask == nil)
    #expect(gateway.lastSearch == "")
  }

  @Test func `duplicate search does not trigger reload`() async throws {
    try await subject.load()
    gateway.reloadCallCount = 0

    try await subject.search(for: "Cloud")
    let debounceTask = subject.searchDebounceTask
    await debounceTask?.value

    // Same search again
    try await subject.search(for: "Cloud")
    await subject.searchDebounceTask?.value

    // Should not trigger another reload
    #expect(subject.searchDebounceTask == debounceTask)
    #expect(gateway.reloadCallCount == 1)
  }

  @Test func `vote updates local feature plans`() async throws {
    try await subject.load()
    let original = try #require(subject.all.first)

    try await subject.vote(original)

    #expect(gateway.voteCallCount == 1)
    #expect(subject.all.count == 3)
  }

  @Test func `unknown feature plan throws public error`() async {
    await #expect(throws: FeaturePlansError.unknownFeaturePlan) {
      try await subject.featurePlan(id: 42)
    }
  }
}

extension FeaturePlansTests {
  private var fixtures: [FeaturePlan] {
    [
      FeaturePlan(
        id: 1,
        title: "Import holidays from calendar",
        body: "Choose an iOS calendar to automatically import and sync holidays in WorkTimes.",
        score: 10,
        status: .open,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 17, hour: 12)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 12)!,
        isVoted: true
      ),
      FeaturePlan(
        id: 2,
        title: "Cloud Sync",
        body: "Sync records and accounts via iCloud on multiple devices.",
        score: 33,
        status: .planned,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 13)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 18, hour: 13)!,
        isVoted: false
      ),
      FeaturePlan(
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

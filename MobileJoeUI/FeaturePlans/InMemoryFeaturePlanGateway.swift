// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoe

@MainActor
class InMemoryFeaturePlanGateway: FeaturePlanGateway {
  var featurePlans: [FeaturePlan]
  private let seedData: [FeaturePlan]
  private var loadError: Swift.Error?

  init(seedData: [FeaturePlan] = [], loadError: Swift.Error? = nil) {
    self.seedData = seedData
    self.featurePlans = Self.sort(seedData, by: .byNewest)
    self.loadError = loadError
  }

  func reload(filterBy statuses: [FeaturePlan.Status]?, sort sorting: FeaturePlan.Sorting, search: String?) async throws {
    try await load(filterBy: statuses, sort: sorting, search: search)
  }

  func load(filterBy statuses: [FeaturePlan.Status]?, sort sorting: FeaturePlan.Sorting, search: String?) async throws {
    if let loadError { throw loadError }
    featurePlans = Self.sort(filter(seedData, by: statuses, search: search), by: sorting)
  }

  func featurePlan(id: Int) async throws -> FeaturePlan {
    if let loadError { throw loadError }
    guard let featurePlan = seedData.first(where: { $0.id == id }) else {
      throw FeaturePlanGatewayError.unknownFeaturePlan
    }
    return featurePlan
  }

  func vote(_ featurePlan: FeaturePlan) async throws {
    var isVoted = featurePlan.isVoted
    isVoted.toggle()

    let votedFeaturePlan = FeaturePlan(
      id: featurePlan.id,
      title: featurePlan.title,
      body: featurePlan.body,
      score: isVoted ? featurePlan.score + 1 : featurePlan.score - 1,
      status: featurePlan.status,
      createdAt: featurePlan.createdAt,
      updatedAt: featurePlan.updatedAt,
      isVoted: isVoted
    )

    featurePlan.update(from: votedFeaturePlan)
  }

  private func filter(_ data: [FeaturePlan], by statuses: [FeaturePlan.Status]?, search: String?) -> [FeaturePlan] {
    var result = data
    if let statuses {
      result = result.filter { statuses.contains($0.status) }
    }
    if let search, !search.isEmpty {
      result = result.filter { $0.title.localizedCaseInsensitiveContains(search) }
    }
    return result
  }

  private static func sort(_ data: [FeaturePlan], by sorting: FeaturePlan.Sorting) -> [FeaturePlan] {
    switch sorting {
    case .byNewest: data.sorted { $0.createdAt > $1.createdAt }
    case .byScore: data.sorted { $0.score > $1.score }
    }
  }
}

// MARK: - Seed Data

extension InMemoryFeaturePlanGateway {
  static var seed: InMemoryFeaturePlanGateway {
    InMemoryFeaturePlanGateway(seedData: seedData)
  }

  private static var seedData: [FeaturePlan] {
    [
      FeaturePlan(
        id: 1,
        title: "Import holidays from calendar",
        body: "Choose an iOS calendar to automatically import and sync holidays in WorkTimes.",
        score: 10,
        status: .open,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 17, hour: 12)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 17, hour: 12)!,
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
        title: "Apple Watch app",
        body: "A companion Apple Watch app to quickly start and stop time tracking without reaching for your phone. Show current timer status and allow quick project switching.",
        score: 87,
        status: .underReview,
        createdAt: Calendar.utc.date(year: 2025, month: 2, day: 10, hour: 9)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 4, day: 5, hour: 14)!,
        isVoted: true
      ),
      FeaturePlan(
        id: 4,
        title: "Export to PDF",
        body: "Generate professional PDF reports of time entries for clients. Include company logo, project breakdown, and hourly summaries.",
        score: 45,
        status: .inProgress,
        createdAt: Calendar.utc.date(year: 2025, month: 1, day: 22, hour: 16)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 4, day: 12, hour: 10)!,
        isVoted: false
      ),
      FeaturePlan(
        id: 5,
        title: "Dark mode improvements",
        body: "The current dark mode has some contrast issues. Improve readability of text and make icons more visible in low-light conditions.",
        score: 28,
        status: .completed,
        createdAt: Calendar.utc.date(year: 2025, month: 1, day: 5, hour: 11)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 1, hour: 9)!,
        isVoted: true
      ),
      FeaturePlan(
        id: 6,
        title: "Recurring time entries",
        body: "Allow setting up recurring time entries for regular meetings or tasks that happen on the same day and time each week.",
        score: 52,
        status: .planned,
        createdAt: Calendar.utc.date(year: 2025, month: 2, day: 28, hour: 14)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 4, day: 8, hour: 16)!,
        isVoted: true
      ),
      FeaturePlan(
        id: 7,
        title: "Widgets for home screen",
        body: "Add iOS widgets to show today's tracked time, current running timer, and quick-start buttons for favorite projects.",
        score: 71,
        status: .inProgress,
        createdAt: Calendar.utc.date(year: 2025, month: 1, day: 15, hour: 8)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 4, day: 10, hour: 11)!,
        isVoted: false
      ),
      FeaturePlan(
        id: 8,
        title: "Pomodoro timer integration",
        body: "Built-in Pomodoro technique support with customizable work/break intervals and automatic time entry creation after each session.",
        score: 19,
        status: .open,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 25, hour: 10)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 25, hour: 10)!,
        isVoted: false
      ),
      FeaturePlan(
        id: 9,
        title: "Team collaboration features",
        body: "Share projects with team members, view team availability, and coordinate schedules. Include manager approval workflow for time entries.",
        score: 64,
        status: .underReview,
        createdAt: Calendar.utc.date(year: 2025, month: 2, day: 5, hour: 13)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 4, day: 2, hour: 15)!,
        isVoted: true
      ),
      FeaturePlan(
        id: 10,
        title: "Location-based automatic tracking",
        body: "Automatically start/stop timers based on GPS location. When I arrive at the office, start work timer. When I leave, stop it.",
        score: 38,
        status: .open,
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 8, hour: 17)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 20, hour: 9)!,
        isVoted: false
      ),
      FeaturePlan(
        id: 11,
        title: "Siri shortcuts support",
        body: "Add Siri shortcuts to start/stop timers, switch projects, and query today's tracked time using voice commands.",
        score: 41,
        status: .planned,
        createdAt: Calendar.utc.date(year: 2025, month: 2, day: 18, hour: 12)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 4, day: 6, hour: 14)!,
        isVoted: true
      ),
      FeaturePlan(
        id: 12,
        title: "Invoice generation",
        body: "Generate invoices directly from tracked time entries. Support multiple currencies, tax rates, and customizable invoice templates.",
        score: 56,
        status: .underReview,
        createdAt: Calendar.utc.date(year: 2025, month: 1, day: 30, hour: 15)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 4, day: 1, hour: 11)!,
        isVoted: false
      ),
    ]
  }
}

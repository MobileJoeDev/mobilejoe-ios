//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  RemoteAlertGatewayTests.swift
//
//  Created by Florian Mielke on 16.10.25.
//

import Foundation
import Testing
@testable import MobileJoe

struct RemoteAlertGatewayTests {
  @Suite("Alert Loading")
  struct AlertLoading {
    let client: APIClientMock
    var gateway: RemoteAlertGateway

    init() {
      client = APIClientMock()
      gateway = RemoteAlertGateway(client: client)
    }

    @Test
    func `load fetches alerts from network`() async throws {
      client.mockGetAlerts = try encodeAlerts([
        makeAlert(id: 1),
        makeAlert(id: 2)
      ])

      #expect(gateway.alerts.isEmpty)

      try await gateway.load()

      #expect(gateway.alerts.count == 2)
      #expect(client.getAlertsCallCount == 1)
    }

    @Test
    func `load handles empty response`() async throws {
      client.mockGetAlerts = try encodeAlerts([])

      try await gateway.load()

      #expect(gateway.alerts.isEmpty)
      #expect(client.getAlertsCallCount == 1)
    }

    @Test
    func `load replaces existing alerts`() async throws {
      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 1)])

      try await gateway.load()
      #expect(gateway.alerts.count == 1)
      #expect(gateway.alerts[0].id == 1)

      // Simulate time passing beyond cache duration
      gateway.lastFetch = Date(timeIntervalSinceNow: -16 * 60)

      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 2)])

      try await gateway.load()
      #expect(gateway.alerts.count == 1)
      #expect(gateway.alerts[0].id == 2)
      #expect(client.getAlertsCallCount == 2)
    }
  }

  @Suite("Caching Behavior")
  struct CachingBehavior {
    let client: APIClientMock
    var gateway: RemoteAlertGateway

    init() {
      client = APIClientMock()
      gateway = RemoteAlertGateway(client: client)
    }

    @Test
    func `first load always fetches from network`() async throws {
      client.mockGetAlerts = try encodeAlerts([])

      try await gateway.load()

      #expect(client.getAlertsCallCount == 1)
      #expect(gateway.alerts.count == 0)
    }

    @Test
    func `subsequent load within 15 minutes skips network call`() async throws {
      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 1)])

      // First load
      try await gateway.load()
      #expect(client.getAlertsCallCount == 1)
      #expect(gateway.alerts.count == 1)
      #expect(gateway.alerts[0].id == 1)

      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 2)])

      // Second load immediately after - should skip
      try await gateway.load()
      #expect(client.getAlertsCallCount == 1) // Still 1, not 2
      #expect(gateway.alerts.count == 1) // Keeps previous alerts
      #expect(gateway.alerts[0].id == 1)
    }

    @Test
    func `load after 15 minutes fetches from network`() async throws {
      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 1)])

      // First load
      try await gateway.load()
      #expect(client.getAlertsCallCount == 1)
      #expect(gateway.alerts.count == 1)
      #expect(gateway.alerts[0].id == 1)

      // Simulate 16 minutes passing (beyond the 15-minute threshold)
      gateway.lastFetch = Date(timeIntervalSinceNow: -16 * 60)
      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 2)])

      // Second load should fetch from network
      try await gateway.load()

      #expect(client.getAlertsCallCount == 2)
      #expect(gateway.alerts.count == 1)
      #expect(gateway.alerts[0].id == 2)
    }
  }

  @Suite("Debug Mode Behavior")
  struct DebugModeBehavior {
    let client: APIClientMock
    var gateway: RemoteAlertGateway

    init() {
      client = APIClientMock()
      client.mockDebugMode = true
      gateway = RemoteAlertGateway(client: client)
    }

    @Test
    func `debug mode bypasses cache on subsequent loads`() async throws {
      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 1)])

      // First load
      try await gateway.load()
      #expect(client.getAlertsCallCount == 1)
      #expect(gateway.alerts.count == 1)
      #expect(gateway.alerts[0].id == 1)

      // Change mock data for second load
      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 2)])

      // Second load immediately after - should NOT skip in debug mode
      try await gateway.load()
      #expect(client.getAlertsCallCount == 2) // Should be 2, not 1
      #expect(gateway.alerts.count == 1)
      #expect(gateway.alerts[0].id == 2) // Should get new data
    }

    @Test
    func `debug mode always fetches even within cache window`() async throws {
      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 1)])

      // First load
      try await gateway.load()
      #expect(client.getAlertsCallCount == 1)

      // Update mock data
      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 2)])

      // Multiple loads immediately after - all should fetch in debug mode
      try await gateway.load()
      #expect(client.getAlertsCallCount == 2)

      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 3)])
      try await gateway.load()
      #expect(client.getAlertsCallCount == 3)

      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 4)])
      try await gateway.load()
      #expect(client.getAlertsCallCount == 4)

      // Verify we got the latest data
      #expect(gateway.alerts.count == 1)
      #expect(gateway.alerts[0].id == 4)
    }

    @Test
    func `debug mode ignores lastFetch timestamp`() async throws {
      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 1)])

      // First load
      try await gateway.load()
      #expect(client.getAlertsCallCount == 1)

      // Manually set lastFetch to 1 second ago (well within cache window)
      gateway.lastFetch = Date(timeIntervalSinceNow: -1)

      client.mockGetAlerts = try encodeAlerts([makeAlert(id: 2)])

      // Should still fetch because debug mode is enabled
      try await gateway.load()
      #expect(client.getAlertsCallCount == 2)
      #expect(gateway.alerts[0].id == 2)
    }
  }
}

// MARK: - Helpers
private func makeAlert(id: Int) -> Alert {
  Alert(
    id: id,
    title: "Alert \(id)",
    message: nil,
    kind: .warning,
    occurredAt: .now,
    createdAt: .now,
    updatedAt: .now
  )
}

private func encodeAlerts(_ alerts: [Alert]) throws -> Data {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .formatted(.apiDateFormatter)
  return try encoder.encode(alerts)
}

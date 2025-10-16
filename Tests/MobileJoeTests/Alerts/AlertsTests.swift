//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  AlertsTests.swift
//
//  Created by Florian Mielke on 10.10.25.
//

import Foundation
import Testing
@testable import MobileJoe

@Suite("Alerts")
struct AlertsTests {
  let gateway: AlertGatewayMock
  let subject: Alerts

  init() {
    gateway = AlertGatewayMock()
    subject = Alerts(gateway: gateway)
    gateway.allReturnValue = fixtures
  }

  @Test
  func `load alerts populates all property`() async throws {
    #expect(subject.all.isEmpty)

    try await subject.load()

    #expect(subject.all.count == 2)
    #expect(!subject.isEmpty)
  }

  @Test
  func `empty state is correct`() async throws {
    gateway.allReturnValue = []

    try await subject.load()

    #expect(subject.isEmpty)
    #expect(subject.all.isEmpty)
  }

  @Test
  func `alerts contain expected data`() async throws {
    try await subject.load()

    let firstAlert = try #require(subject.all.first)
    #expect(firstAlert.id == 1)
    #expect(firstAlert.title == "Performance Issue")
  }

  @Test(arguments: [Alert.Kind.warning, Alert.Kind.error])
  func `alert kinds decode correctly`(kind: Alert.Kind) async throws {
    let alert = Alert(
      id: 1,
      title: "Test",
      message: "Test message",
      kind: kind,
      occurredAt: .now,
      createdAt: .now,
      updatedAt: .now
    )

    gateway.allReturnValue = [alert]
    try await subject.load()

    let loadedAlert = try #require(subject.all.first)
    #expect(loadedAlert.kind == kind)
  }
}

extension AlertsTests {
  private var fixtures: [Alert] {
    [
      Alert(
        id: 1,
        title: "Performance Issue",
        message: "We're experiencing slower response times",
        kind: .warning,
        occurredAt: Calendar.utc.date(year: 2025, month: 10, day: 9, hour: 14)!,
        createdAt: Calendar.utc.date(year: 2025, month: 10, day: 9, hour: 14)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 10, day: 9, hour: 15)!
      ),
      Alert(
        id: 2,
        title: "Service Outage",
        message: "API services are temporarily unavailable",
        kind: .error,
        occurredAt: Calendar.utc.date(year: 2025, month: 10, day: 8, hour: 10)!,
        createdAt: Calendar.utc.date(year: 2025, month: 10, day: 8, hour: 10)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 10, day: 8, hour: 11)!
      )
    ]
  }
}

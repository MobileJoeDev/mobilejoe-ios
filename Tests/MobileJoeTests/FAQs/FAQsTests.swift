// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

@Suite("FAQs")
struct FAQsTests {
  let gateway: FAQGatewayMock
  let subject: FAQs

  init() {
    gateway = FAQGatewayMock()
    subject = FAQs(gateway: gateway)
    gateway.allReturnValue = fixtures
  }

  @Test
  func `load FAQs populates all property`() async throws {
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
  func `FAQs contain expected data`() async throws {
    try await subject.load()

    let firstFAQ = try #require(subject.all.first)
    #expect(firstFAQ.id == 1)
    #expect(firstFAQ.title == "How do I reset my password?")
  }

  @Test
  func `FAQs are sorted by position`() async throws {
    try await subject.load()

    let positions = subject.all.map(\.position)
    #expect(positions == [1, 2])
  }
}

extension FAQsTests {
  private var fixtures: [FAQItem] {
    [
      FAQItem(
        id: 1,
        title: "How do I reset my password?",
        body: "Click the 'Forgot Password' link on the login page.",
        position: 1,
        createdAt: Calendar.utc.date(year: 2026, month: 1, day: 9, hour: 14)!,
        updatedAt: Calendar.utc.date(year: 2026, month: 1, day: 9, hour: 15)!
      ),
      FAQItem(
        id: 2,
        title: "How do I create an account?",
        body: "Navigate to the signup page and fill in the required fields.",
        position: 2,
        createdAt: Calendar.utc.date(year: 2026, month: 1, day: 8, hour: 10)!,
        updatedAt: Calendar.utc.date(year: 2026, month: 1, day: 8, hour: 11)!
      )
    ]
  }
}

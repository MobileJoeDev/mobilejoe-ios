// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct RemoteFAQGatewayTests {
  @Suite("FAQ Loading")
  struct FAQLoading {
    let client: APIClientMock
    var gateway: RemoteFAQGateway

    init() {
      client = APIClientMock()
      gateway = RemoteFAQGateway(client: client)
    }

    @Test
    func `load fetches FAQs from network`() async throws {
      client.mockGetFAQs = try encodeFAQs([
        makeFAQ(id: 1),
        makeFAQ(id: 2)
      ])

      #expect(gateway.faqs.isEmpty)

      try await gateway.load()

      #expect(gateway.faqs.count == 2)
      #expect(client.getFAQsCallCount == 1)
    }

    @Test
    func `load handles empty response`() async throws {
      client.mockGetFAQs = try encodeFAQs([])

      try await gateway.load()

      #expect(gateway.faqs.isEmpty)
      #expect(client.getFAQsCallCount == 1)
    }

    @Test(arguments: [false, true])
    func loadReplacesExistingFAQsWithoutDelay(isDebugMode: Bool) async throws {
      client.mockDebugMode = isDebugMode
      client.mockGetFAQs = try encodeFAQs([makeFAQ(id: 1)])

      try await gateway.load()
      #expect(gateway.faqs.count == 1)
      #expect(gateway.faqs[0].id == 1)

      client.mockGetFAQs = try encodeFAQs([makeFAQ(id: 2)])

      try await gateway.load()
      #expect(gateway.faqs.count == 1)
      #expect(gateway.faqs[0].id == 2)
      #expect(client.getFAQsCallCount == 2)
    }
  }
}

// MARK: - Helpers
private func makeFAQ(id: Int) -> FAQItem {
  FAQItem(
    id: id,
    title: "FAQ \(id)",
    body: "Answer for FAQ \(id)",
    position: id,
    createdAt: .now,
    updatedAt: .now
  )
}

private func encodeFAQs(_ faqs: [FAQItem]) throws -> Data {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .formatted(.apiDateFormatter)
  return try encoder.encode(faqs)
}

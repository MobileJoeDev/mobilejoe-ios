// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoe

@MainActor
class InMemoryFAQGateway: FAQGateway {
  var faqs: [FAQItem]
  private let seedData: [FAQItem]
  private var loadError: Swift.Error?

  init(seedData: [FAQItem] = [], loadError: Swift.Error? = nil) {
    self.seedData = seedData
    self.faqs = seedData
    self.loadError = loadError
  }

  func load() async throws {
    if let loadError { throw loadError }
    faqs = seedData
  }
}

// MARK: - Seed Data

extension InMemoryFAQGateway {
  static var seed: InMemoryFAQGateway {
    InMemoryFAQGateway(seedData: seedData)
  }

  private static var seedData: [FAQItem] {
    [
      FAQItem(
        id: 1,
        title: "How do I reset my password?",
        body: "Click the 'Forgot Password' link on the login page and follow the instructions sent to your email.",
        position: 1,
        createdAt: .distantPast,
        updatedAt: .distantPast
      ),
      FAQItem(
        id: 2,
        title: "How do I create an account if I already signed up with a different email address?",
        body: "Navigate to the signup page and fill in the required fields including your email and password.",
        position: 2,
        createdAt: .distantPast,
        updatedAt: .distantPast
      ),
      FAQItem(
        id: 3,
        title: "How can I contact support?",
        body: "You can reach our support team via email at support@example.com or through the in-app chat feature.",
        position: 3,
        createdAt: .distantPast,
        updatedAt: .distantPast
      )
    ]
  }

  static var singleFAQ: [FAQItem] {
    [
      FAQItem(
        id: 1,
        title: "How do I reset my password?",
        body: "Click the 'Forgot Password' link on the login page and follow the instructions sent to your email.",
        position: 1,
        createdAt: .distantPast,
        updatedAt: .distantPast
      )
    ]
  }
}

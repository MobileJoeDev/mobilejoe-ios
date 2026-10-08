// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

class RemoteFAQGateway: FAQGateway {
  static let shared = RemoteFAQGateway()

  private let client: APIClient

  init(client: APIClient = NetworkClient.shared) {
    self.client = client
  }

  var faqs = [FAQItem]()

  func load() async throws {
    let response = try await client.getFAQs()
    faqs = try Parser().parse(response)
  }
}

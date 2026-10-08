// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

/// Builds an RFC 6068 `mailto:` URL.
package nonisolated struct MailToURL {
  private let recipient: String
  private let subject: LocalizedStringResource?
  private let body: LocalizedStringResource?

  package init(
    recipient: String,
    subject: LocalizedStringResource?,
    body: LocalizedStringResource?
  ) {
    self.recipient = recipient
    self.subject = subject
    self.body = body
  }

  /// `nil` when there is nobody to write to, which is what hides the contact UI.
  package var url: URL? {
    guard recipient.isNotEmpty else { return nil }
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = recipient
    let queryItems = [
      subject.map { URLQueryItem(name: "subject", value: String(localized: $0)) },
      body.map { URLQueryItem(name: "body", value: String(localized: $0)) }
    ].compactMap { $0 }
    // An empty array still renders a trailing "?", so drop it entirely instead.
    components.queryItems = queryItems.isNotEmpty ? queryItems : nil
    return components.url
  }
}

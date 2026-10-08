// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct MailToURLTests {
  @Test
  func `empty recipient returns nil`() {
    let subject = MailToURL(recipient: "", subject: nil, body: nil)

    #expect(subject.url == nil)
  }

  @Test
  func `recipient without mail content has no query`() throws {
    let subject = MailToURL(
      recipient: "support@example.com",
      subject: nil,
      body: nil
    )

    let url = try #require(subject.url)

    #expect(url.absoluteString == "mailto:support@example.com")
  }

  @Test
  func `nil mail content is omitted`() throws {
    let subject = MailToURL(
      recipient: "support@example.com",
      subject: "Support request",
      body: nil
    )

    let url = try #require(subject.url)

    #expect(url.absoluteString == "mailto:support@example.com?subject=Support%20request")
  }

  @Test
  func `body can be provided without subject`() throws {
    let subject = MailToURL(
      recipient: "support@example.com",
      subject: nil,
      body: "More details"
    )

    let url = try #require(subject.url)

    #expect(url.absoluteString == "mailto:support@example.com?body=More%20details")
  }

  @Test
  func `empty mail content is preserved`() throws {
    let subject = MailToURL(
      recipient: "support@example.com",
      subject: "",
      body: ""
    )

    let url = try #require(subject.url)

    #expect(url.absoluteString == "mailto:support@example.com?subject=&body=")
  }

  @Test
  func `mail content is percent encoded`() throws {
    let subject = MailToURL(
      recipient: "support@example.com",
      subject: "Support & feedback",
      body: "First line\nSecond line?"
    )

    let url = try #require(subject.url)

    #expect(
      url.absoluteString ==
        "mailto:support@example.com?subject=Support%20%26%20feedback&body=First%20line%0ASecond%20line?"
    )
  }
}

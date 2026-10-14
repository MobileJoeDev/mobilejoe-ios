// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoe

extension FAQView {
  /// Configure this to show additional contact support information below the FAQ list and below each FAQ item in the `FAQDetailView`.
  /// **Note:** The information is only being presented if `recipient` is not empty.
  public struct Configuration: Sendable {
    let recipient: String
    let subject: LocalizedStringResource?
    let body: LocalizedStringResource?
    let contactSupportMailToLabel: LocalizedStringResource
    let contactSupportHint: LocalizedStringResource

    /// Creates a configuration using `MobileJoeUI`'s localized contact-support strings.
    public static func standard(recipient: String) -> Self {
      Self(
        recipient: recipient,
        contactSupportMailToLabel: .init("faq.configuration.contact-support-mail-to", bundle: .module),
        contactSupportHint: .init("faq.configuration.contact-support-hint", bundle: .module)
      )
    }

    /// Creates a configuration using developer-provided localized contact-support content.
    public init(
      recipient: String,
      subject: LocalizedStringResource? = nil,
      body: LocalizedStringResource? = nil,
      contactSupportMailToLabel: LocalizedStringResource,
      contactSupportHint: LocalizedStringResource
    ) {
      self.recipient = recipient
      self.subject = subject
      self.body = body
      self.contactSupportMailToLabel = contactSupportMailToLabel
      self.contactSupportHint = contactSupportHint
    }

    public var mailToURL: URL? {
      MailToURL(recipient: recipient, subject: subject, body: body).url
    }
  }
}

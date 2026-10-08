// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoe

extension FeaturePlansView {
  /// Configure this to show a contact support button in the `FeaturePlanListView`.
  /// **Note:** The button is only being presented if `recipient` is not empty.
  public struct Configuration: Sendable {
    let recipient: String
    let subject: LocalizedStringResource?
    let body: LocalizedStringResource?

    /// Creates a configuration using `MobileJoeUI`'s localized mail subject.
    public static func standard(recipient: String) -> Self {
      Self(
        recipient: recipient,
        subject: .init("feature-plan.configuration.subject", bundle: .module),
        body: nil
      )
    }

    /// Creates a configuration using developer-provided localized mail content.
    public init(
      recipient: String,
      subject: LocalizedStringResource?,
      body: LocalizedStringResource?
    ) {
      self.recipient = recipient
      self.subject = subject
      self.body = body
    }

    public var mailToURL: URL? {
      MailToURL(recipient: recipient, subject: subject, body: body).url
    }
  }
}

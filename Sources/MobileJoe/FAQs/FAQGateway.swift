// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

public protocol FAQGateway {
  var faqs: [FAQItem] { get }
  func load() async throws
}

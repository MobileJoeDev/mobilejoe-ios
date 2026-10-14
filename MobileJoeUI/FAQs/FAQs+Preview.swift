// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoe

@MainActor
extension FAQs {
  public static var preview: FAQs {
    let gateway = InMemoryFAQGateway.seed
    let faqs = FAQs(gateway: gateway)
    faqs.all = gateway.faqs
    return faqs
  }

  public static var previewEmpty: FAQs {
    FAQs(gateway: InMemoryFAQGateway())
  }

  public static var previewFailed: FAQs {
    let gateway = InMemoryFAQGateway(loadError: URLError(.notConnectedToInternet))
    let faqs = FAQs(gateway: gateway)
    faqs.all = []
    return faqs
  }
}

// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

struct FAQDetailView: View {
  let faqItem: FAQItem
  let configuration: FAQView.Configuration

  var body: some View {
    Form {
      VStack(alignment: .leading, spacing: 20) {
        Text(faqItem.title)
          .font(.title3)
          .fontWeight(.semibold)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)

        Text(faqItem.body)

        if let mailToURL = configuration.mailToURL {
          FAQContactSupportView(configuration: configuration, mailToURL: mailToURL)
            .padding(.top)
        }
      }
      .fixedSize(horizontal: false, vertical: true)
      .padding(.vertical, 10)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .navigationTitle(String(localized: "faq.detail.title", bundle: .module))
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview("With Support Hint") {
  NavigationStack {
    FAQDetailView(
      faqItem: FAQs.preview.all.first!,
      configuration: .standard(recipient: "hey@mobilejoe.dev")
    )
  }
}

#Preview("No Support Hint") {
  NavigationStack {
    FAQDetailView(
      faqItem: FAQs.preview.all.first!,
      configuration: .standard(recipient: "")
    )
  }
}

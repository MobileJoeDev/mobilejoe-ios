// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

struct FAQListRow: View {
  let faqItem: FAQItem

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(faqItem.title)
        .font(.headline)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)

      Text(faqItem.body)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(2)
    }
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  List {
    FAQListRow(faqItem: FAQs.preview.all.first!)
  }
}

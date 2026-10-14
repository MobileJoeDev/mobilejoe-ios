// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

struct FAQListRow: View {
  let faqItem: FAQItem

  var body: some View {
    Text(faqItem.title)
      .font(.headline)
      .multilineTextAlignment(.leading)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  List {
    ForEach(FAQs.preview.all) { faqItem in
      FAQListRow(faqItem: faqItem)
    }
  }
}

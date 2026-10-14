// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

struct FAQContactSupportView: View {
  let configuration: FAQView.Configuration
  let mailToURL: URL

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(configuration.contactSupportHint)
      Link(destination: mailToURL) {
        Text(configuration.contactSupportMailToLabel)
      }
      .buttonStyle(.borderless)
    }
  }
}

#Preview {
  let configuration = FAQView.Configuration.standard(recipient: "hey@mobilejoe.dev")
  List {
    FAQContactSupportView(configuration: configuration, mailToURL: configuration.mailToURL!)
  }
}

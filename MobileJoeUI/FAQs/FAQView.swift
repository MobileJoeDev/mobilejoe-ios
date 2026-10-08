// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

public struct FAQView: View {
  let faqs: FAQs
  let presentationMode: PresentationMode
  let configuration: Configuration

  public var body: some View {
    switch presentationMode {
    case .asSheet:
      NavigationStack {
        FAQListView(
          faqs: faqs,
          presentationMode: presentationMode,
          configuration: configuration
        )
      }
    case .inNavigationStack:
      FAQListView(
        faqs: faqs,
        presentationMode: presentationMode,
        configuration: configuration
      )
    }
  }

  public init(presentationMode: PresentationMode, configuration: Configuration) {
    self.init(
      faqs: FAQs(),
      presentationMode: presentationMode,
      configuration: configuration
    )
  }

  public init(faqs: FAQs, presentationMode: PresentationMode, configuration: Configuration) {
    self.faqs = faqs
    self.presentationMode = presentationMode
    self.configuration = configuration
  }
}


#Preview("All") {
  NavigationStack {
    FAQView(
      faqs: .preview,
      presentationMode: .inNavigationStack,
      configuration: .standard(recipient: "")
    )
  }
}

#Preview("Empty") {
  NavigationStack {
    FAQView(
      faqs: .previewEmpty,
      presentationMode: .inNavigationStack,
      configuration: .standard(recipient: "")
    )
  }
}

#Preview("Failure") {
  NavigationStack {
    FAQView(
      faqs: .previewFailed,
      presentationMode: .inNavigationStack,
      configuration: .standard(recipient: "")
    )
  }
}

#Preview("Sheet") {
  Text("Sheet")
    .sheet(isPresented: .constant(true)) {
      FAQView(
        faqs: .preview,
        presentationMode: .asSheet,
        configuration: .standard(recipient: "")
      )
    }
}

// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

public struct FeaturePlansView: View {
  let featurePlans: FeaturePlans
  let presentationMode: PresentationMode
  let configuration: Configuration
  let selectedFeaturePlanID: Int?

  public var body: some View {
    switch presentationMode {
    case .asSheet:
      NavigationStack {
        FeaturePlanListView(
          featurePlans: featurePlans,
          presentationMode: presentationMode,
          configuration: configuration,
          selectedFeaturePlanID: selectedFeaturePlanID
        )
      }
    case .inNavigationStack:
      FeaturePlanListView(
        featurePlans: featurePlans,
        presentationMode: presentationMode,
        configuration: configuration,
        selectedFeaturePlanID: selectedFeaturePlanID
      )
    }
  }

  public init(configuration: FeaturePlansView.Configuration, presentationMode: PresentationMode, selectedFeaturePlanID: Int? = nil) {
    self.featurePlans = FeaturePlans()
    self.presentationMode = presentationMode
    self.configuration = configuration
    self.selectedFeaturePlanID = selectedFeaturePlanID
  }

  public init(featurePlans: FeaturePlans, presentationMode: PresentationMode, configuration: Configuration, selectedFeaturePlanID: Int? = nil) {
    self.featurePlans = featurePlans
    self.presentationMode = presentationMode
    self.configuration = configuration
    self.selectedFeaturePlanID = selectedFeaturePlanID
  }
}


#Preview("All") {
  NavigationStack {
    FeaturePlansView(
      featurePlans: .preview,
      presentationMode: .inNavigationStack,
      configuration: .standard(recipient: "hey@mobilejoe.dev"),
    )
  }
}

#Preview("Selection") {
  NavigationStack {
    FeaturePlansView(
      featurePlans: .preview,
      presentationMode: .inNavigationStack,
      configuration: .standard(recipient: "hey@mobilejoe.dev"),
      selectedFeaturePlanID: 3
    )
  }
}

#Preview("Empty") {
  NavigationStack {
    FeaturePlansView(
      featurePlans: .previewEmpty,
      presentationMode: .inNavigationStack,
      configuration: .standard(recipient: "hey@mobilejoe.dev")
    )
  }
}

#Preview("Failure") {
  NavigationStack {
    FeaturePlansView(
      featurePlans: .previewFailed,
      presentationMode: .inNavigationStack,
      configuration: .standard(recipient: "hey@mobilejoe.dev")
    )
  }
}

#Preview("Sheet") {
  Text("Sheet")
    .sheet(isPresented: .constant(true)) {
      FeaturePlansView(
        featurePlans: .preview,
        presentationMode: .asSheet,
        configuration: .standard(recipient: "hey@mobilejoe.dev")
      )
    }
}

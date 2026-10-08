// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe
import MobileJoeUI

struct FeatureListView: View {
  @State private var showingFeaturePlan = false
  @State private var showingFAQ = false

  var body: some View {
    NavigationStack {
      Form {
        Section {
          NavigationLink {
            /// In this sample we inject feature plan previews. In your own implementation simply
            /// call `FeaturePlansView(configuration:presentationMode:)`.
            FeaturePlansView(
              featurePlans: .preview,
              presentationMode: .inNavigationStack,
              configuration: .standard(recipient: "support@mobilejoe.dev")
            )
          } label: {
            Label("Feature Plans", systemImage: "lightbulb.circle.fill")
          }

          NavigationLink {
            /// In this sample we inject feature plan previews. In your own implementation simply
            /// call `FeaturePlansView(configuration:presentationMode:)`.
            FeaturePlansView(
              featurePlans: .preview,
              presentationMode: .inNavigationStack,
              configuration: .standard(recipient: "support@mobilejoe.dev"),
              selectedFeaturePlanID: 2
            )
          } label: {
            Label {
              Text("Feature Plans")
              Text("With selected feature plan ID 2")
            } icon: {
              Image(systemName: "lightbulb.circle.fill")
            }
          }

          Button {
            showingFeaturePlan.toggle()
          } label: {
            Label {
              Text("Feature Plans")
              Text("As sheet")
            } icon: {
              Image(systemName: "lightbulb.circle.fill")
            }
          }
          .sheet(isPresented: $showingFeaturePlan) {
            /// In this sample we inject feature plan previews. In your own implementation simply
            /// call `FeaturePlansView(configuration:presentationMode:)`.
            FeaturePlansView(
              featurePlans: .preview,
              presentationMode: .asSheet,
              configuration: .standard(recipient: "hey@mobilejoe.dev")
            )
          }
        }

        Section {
          NavigationLink {
            FAQView(
              faqs: .preview,
              presentationMode: .inNavigationStack,
              configuration: .standard(recipient: "hey@mobilejoe.dev")
            )
          } label: {
            Label("FAQs", systemImage: "questionmark.circle.fill")
          }

          Button {
            showingFAQ.toggle()
          } label: {
            Label {
              Text("FAQs")
              Text("As sheet")
            } icon: {
              Image(systemName: "questionmark.circle.fill")
            }
          }
          .sheet(isPresented: $showingFAQ) {
            FAQView(
              faqs: .preview,
              presentationMode: .asSheet,
              configuration: .standard(recipient: "hey@mobilejoe.dev")
            )
          }
        }

        Section {
          NavigationLink {
            AlertsSampleView()
          } label: {
            Label("Alerts", systemImage: "bell.circle.fill")
          }
        }
      }
      .navigationTitle("Sample Joe")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  FeatureListView()
}

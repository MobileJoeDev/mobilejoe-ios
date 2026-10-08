// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe
import MobileJoeUI

struct AlertsSampleView: View {
  @State private var showingMoreAlerts = false

  var body: some View {
    List {
      Section {
        Text("This might be your main UI")
      }

      Section {
        Button("Toggle more alert samples") {
          showingMoreAlerts.toggle()
        }
      }
    }
    .navigationTitle("Alerts")
    .safeAreaBar(edge: .top) {
      /// In this sample we inject alert previews. In your own implementation simply
      /// call `AlertsView()`.
      AlertsView(alerts: .previewSingle)
        .padding()
    }
    .safeAreaBar(edge: .bottom) {
      if showingMoreAlerts {
        AlertsView(alerts: .preview)
          .padding()
      }
    }
  }
}

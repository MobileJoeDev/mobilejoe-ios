// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe
import OSLog

@main
struct SampleJoeApp: App {
  var body: some Scene {
    WindowGroup {
      FeatureListView()
        .task {
          try? await Joe.configure(withAPIKey: "YOUR_MOBILE_JOE_API_KEY")
        }
    }
  }
}

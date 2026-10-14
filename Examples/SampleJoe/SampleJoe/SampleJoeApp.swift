// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe
import OSLog

@main
struct SampleJoeApp: App {
  init() {
    try? Joe.configure(withAPIKey: "YOUR_MOBILE_JOE_API_KEY")
  }

  var body: some Scene {
    WindowGroup {
      FeatureListView()
    }
  }
}

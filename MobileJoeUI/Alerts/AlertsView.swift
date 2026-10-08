// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

public struct AlertsView: View {
  @Environment(\.scenePhase) var scenePhase
  @State var alerts: Alerts

  public var body: some View {
    VStack {
      ForEach(alerts.all) { alert in
        AlertView(alert: alert)
          .clipShape(.capsule)
      }
    }
    .onChange(of: scenePhase) { oldPhase, newPhase in
      if newPhase == .active {
        reload()
      }
    }
    .task {
      try? await alerts.load()
    }
  }

  public init() {
    self.init(alerts: Alerts())
  }

  public init(alerts: Alerts) {
    self.alerts = alerts
  }
}

extension AlertsView {
  private func reload() {
    Task {
      try? await alerts.load()
    }
  }
}

#Preview {
  AlertsView(alerts: .preview)
}

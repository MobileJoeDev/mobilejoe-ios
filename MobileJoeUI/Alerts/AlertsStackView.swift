//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  AlertsStackView.swift
//
//  Created by Florian Mielke on 26.09.25.
//

import SwiftUI
import MobileJoe

public struct AlertsStackView: View {
  @State var alerts: Alerts

  public var body: some View {
    VStack {
      ForEach(alerts.all) { alert in
        AlertView(alert: alert)
          .clipShape(.capsule)
      }
    }
    .task {
      try? await alerts.load()
    }
  }

  public init() {
    self.init(alerts: Alerts())
  }

  init(alerts: Alerts) {
    self.alerts = alerts
  }
}

#Preview {
  AlertsStackView(alerts: AlertsFixture.multiple)
}

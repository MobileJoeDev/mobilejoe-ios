// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoe

@MainActor
extension Alerts {
  public static var preview: Alerts {
    let gateway = InMemoryAlertGateway.seed
    let alerts = Alerts(gateway: gateway)
    alerts.all = gateway.alerts
    return alerts
  }

  public static var previewSingle: Alerts {
    let gateway = InMemoryAlertGateway(seedData: InMemoryAlertGateway.singleAlert)
    let alerts = Alerts(gateway: gateway)
    alerts.all = gateway.alerts
    return alerts
  }

  public static var previewEmpty: Alerts {
    Alerts(gateway: InMemoryAlertGateway())
  }
}

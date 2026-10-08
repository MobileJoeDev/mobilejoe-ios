// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

extension FeaturePlans {
  public static var preview: FeaturePlans {
    let gateway = InMemoryFeaturePlanGateway.seed
    let featurePlans = FeaturePlans(gateway: gateway)
    featurePlans.all = gateway.featurePlans
    return featurePlans
  }

  public static var previewEmpty: FeaturePlans {
    FeaturePlans(gateway: InMemoryFeaturePlanGateway())
  }

  public static var previewFailed: FeaturePlans {
    let gateway = InMemoryFeaturePlanGateway(loadError: URLError(.notConnectedToInternet))
    let featurePlans = FeaturePlans(gateway: gateway)
    featurePlans.all = []
    return featurePlans
  }
}

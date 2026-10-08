// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

public protocol FeaturePlanGateway {
  var featurePlans: [FeaturePlan] { get }
  func reload(filterBy statuses: [FeaturePlan.Status]?, sort sorting: FeaturePlan.Sorting, search: String?) async throws
  func load(filterBy statuses: [FeaturePlan.Status]?, sort sorting: FeaturePlan.Sorting, search: String?) async throws
  func featurePlan(id: Int) async throws -> FeaturePlan
  func vote(_ featurePlan: FeaturePlan) async throws
}

enum FeaturePlanGatewayError: Error {
  case unknownFeaturePlan
}

// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

class RemoteFeaturePlanGateway: FeaturePlanGateway {
  static var shared = RemoteFeaturePlanGateway()

  private let client: NetworkClient
  private var pagination: Pagination

  init(client: NetworkClient = NetworkClient.shared, pagination: Pagination = Pagination()) {
    self.client = client
    self.pagination = pagination
  }

  var featurePlans = [FeaturePlan]()

  func reload(filterBy statuses: [FeaturePlan.Status]?, sort sorting: FeaturePlan.Sorting, search: String?) async throws {
    pagination = Pagination()
    featurePlans.removeAll()
    guard let nextPage = pagination.nextPage else { return }
    let response = try await client.getFeaturePlans(filterBy: statuses, sort: sorting, search: search, page: nextPage)
    pagination = response.pagination
    let result: [FeaturePlan] = try Parser().parse(response.data)
    featurePlans = result
  }

  func load(filterBy statuses: [FeaturePlan.Status]?, sort sorting: FeaturePlan.Sorting, search: String?) async throws {
    guard let nextPage = pagination.nextPage else { return }
    let response = try await client.getFeaturePlans(filterBy: statuses, sort: sorting, search: search, page: nextPage)
    pagination = response.pagination
    let result: [FeaturePlan] = try Parser().parse(response.data)
    featurePlans.append(contentsOf: result)
  }

  func featurePlan(id: Int) async throws -> FeaturePlan {
    do {
      let response = try await client.getFeaturePlan(id: id)
      return try Parser().parse(response)
    } catch MobileJoeError.httpFailure(statusCode: 404, _, _) {
      throw FeaturePlanGatewayError.unknownFeaturePlan
    }
  }

  func vote(_ featurePlan: FeaturePlan) async throws {
    let response = try await client.postFeaturePlanVote(featurePlanID: featurePlan.id)
    let votedFeaturePlan: FeaturePlan = try Parser().parse(response)
    featurePlan.update(from: votedFeaturePlan)
  }
}

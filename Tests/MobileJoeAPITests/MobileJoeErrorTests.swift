// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoe
import Testing

struct MobileJoeErrorTests {
  @Test(arguments: [
    (MobileJoeError.notConfigured, 1001),
    (.unknownIdentity, 1002),
    (.invalidURL(components: URLComponents()), 1003),
    (.invalidHTTPResponse, 1004),
    (.httpFailure(statusCode: 401, method: "POST", path: "/v1/identify"), 1005),
    (.httpFailure(statusCode: 503, method: "GET", path: "/v1/faqs"), 1005),
    (.invalidAppUserID, 1006),
    (.invalidAPIKey, 1007)
  ])
  func `stable monitoring identifiers and readable messages`(error: MobileJoeError, code: Int) throws {
    let erased: any Error = error
    let bridged = erased as NSError
    let description = try #require(error.errorDescription)

    #expect(bridged.domain == "MobileJoeError")
    #expect(bridged.code == code)
    #expect(!description.isEmpty)
    #expect(!description.hasPrefix("sdk.error."))
    #expect(erased.localizedDescription == description)
    #expect(bridged.localizedDescription == description)
    #expect(bridged.userInfo[NSLocalizedDescriptionKey] as? String == description)
  }

  @Test func `catches SDK cases through error existential`() {
    let error: any Error = MobileJoeError.httpFailure(statusCode: 429, method: "GET", path: "/v1/faqs")
    do {
      throw error
    } catch MobileJoeError.httpFailure(statusCode: 429, let method, let path) {
      #expect(method == "GET")
      #expect(path == "/v1/faqs")
    } catch {
      Issue.record("Expected a publicly catchable HTTP failure, got \(error)")
    }
  }

  @Test func `bridges HTTP context`() {
    let error = MobileJoeError.httpFailure(statusCode: 403, method: "POST", path: "/v1/feature_plans/42/vote")
    let bridged = error as NSError

    #expect(bridged.userInfo["statusCode"] as? Int == 403)
    #expect(bridged.userInfo["method"] as? String == "POST")
    #expect(bridged.userInfo["path"] as? String == "/v1/feature_plans/42/vote")
    #expect(String(reflecting: error) == "MobileJoeError.httpFailure: POST /v1/feature_plans/42/vote returned HTTP 403")
  }

  @Test func `diagnostics omit invalid URL contents`() throws {
    let components = try #require(URLComponents(string: "https://example.com/faqs?search=private-search"))
    let error = MobileJoeError.invalidURL(components: components)

    #expect(String(reflecting: error) == "MobileJoeError.invalidURL")
    #expect(!String(describing: (error as NSError).userInfo).contains("private-search"))
  }

  @Test(arguments: [
    MobileJoeError.notConfigured,
    MobileJoeError.unknownIdentity,
    MobileJoeError.invalidURL(components: URLComponents()),
    MobileJoeError.invalidHTTPResponse,
    MobileJoeError.httpFailure(statusCode: 503, method: "GET", path: "/v1/faqs"),
    MobileJoeError.invalidAppUserID,
    MobileJoeError.invalidAPIKey,
    FeaturePlansError.unknownFeaturePlan
  ] as [any LocalizedError])
  func `errors are localized away from main actor`(error: any LocalizedError) async throws {
    let description = try await Task.detached {
      try #require(error.errorDescription)
    }.value
    #expect(!description.isEmpty)
    #expect(!description.hasPrefix("sdk.error."))
    #expect(!description.hasPrefix("feature-plans.error."))
    #expect((error as NSError).localizedDescription == description)
  }
}

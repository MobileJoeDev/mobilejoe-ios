// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct RouterTests {
  private let session: URLSession
  private let router: DefaultRouter

  init() {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [ResponseURLProtocol.self]
    session = URLSession(configuration: configuration)
    router = DefaultRouter(session: session)
  }

  @Test(arguments: [401, 404, 429, 500, 503])
  func httpFailuresIncludeRequestContext(statusCode: Int) async throws {
    defer { session.invalidateAndCancel() }
    let url = try #require(URL(string: "https://example.com/\(statusCode)?search=private-search"))
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer private-key", forHTTPHeaderField: "Authorization")

    let error = try #require(await #expect(throws: MobileJoeError.self) {
      try await router.perform(request)
    })
    guard case let .httpFailure(actualStatus, method, path) = error else {
      Issue.record("Expected an HTTP failure")
      return
    }
    #expect(actualStatus == statusCode)
    #expect(method == "POST")
    #expect(path == "/\(statusCode)")
    let diagnostics = String(reflecting: error) + String(describing: (error as NSError).userInfo)
    #expect(!diagnostics.contains("private-search"))
    #expect(!diagnostics.contains("private-key"))
  }

  @Test func rejectsNonHTTPResponses() async throws {
    defer { session.invalidateAndCancel() }
    let url = try #require(URL(string: "https://example.com/non-http"))
    let error = await #expect(throws: MobileJoeError.self) {
      try await router.perform(URLRequest(url: url))
    }
    guard case .invalidHTTPResponse = error else {
      Issue.record("Expected an invalid HTTP response error")
      return
    }
  }

  @Test(arguments: [URLError.Code.notConnectedToInternet, .cancelled])
  func preservesTransportErrors(code: URLError.Code) async throws {
    defer { session.invalidateAndCancel() }
    let url = try #require(URL(string: "https://example.com/\(code.rawValue)"))
    let error = try #require(await #expect(throws: URLError.self) {
      try await router.perform(URLRequest(url: url))
    })
    #expect(error.code == code)
  }
}

private nonisolated final class ResponseURLProtocol: URLProtocol, @unchecked Sendable {
  override class func canInit(with request: URLRequest) -> Bool { true }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    guard let url = request.url else { return }
    let response: URLResponse
    if let code = Int(url.lastPathComponent) {
      if code < 0 {
        client?.urlProtocol(self, didFailWithError: URLError(URLError.Code(rawValue: code)))
        return
      }
      response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
    } else {
      response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

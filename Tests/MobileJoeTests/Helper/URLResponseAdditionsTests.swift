// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Testing
import Foundation
@testable import MobileJoe

struct URLResponseAdditionsTests {
  @Test
  func `isSuccessful returns true for 200 OK`() throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )

    #expect(response?.isSuccessful == true)
  }

  @Test
  func `isSuccessful returns true for 201 Created`() throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 201,
      httpVersion: nil,
      headerFields: nil
    )

    #expect(response?.isSuccessful == true)
  }

  @Test
  func `isSuccessful returns true for 204 No Content`() throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 204,
      httpVersion: nil,
      headerFields: nil
    )

    #expect(response?.isSuccessful == true)
  }

  @Test
  func `isSuccessful returns true for 299 at upper boundary`() throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 299,
      httpVersion: nil,
      headerFields: nil
    )

    #expect(response?.isSuccessful == true)
  }

  @Test
  func `isSuccessful returns false for 199 below range`() throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 199,
      httpVersion: nil,
      headerFields: nil
    )

    #expect(response?.isSuccessful == false)
  }

  @Test
  func `isSuccessful returns false for 300 Multiple Choices`() throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 300,
      httpVersion: nil,
      headerFields: nil
    )

    #expect(response?.isSuccessful == false)
  }

  @Test
  func `isSuccessful returns false for 400 Bad Request`() throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 400,
      httpVersion: nil,
      headerFields: nil
    )

    #expect(response?.isSuccessful == false)
  }

  @Test
  func `isSuccessful returns false for non-HTTPURLResponse`() throws {
    let url = URL(string: "https://example.com")!
    let response = URLResponse(
      url: url,
      mimeType: nil,
      expectedContentLength: 0,
      textEncodingName: nil
    )

    #expect(response.isSuccessful == false)
  }
}

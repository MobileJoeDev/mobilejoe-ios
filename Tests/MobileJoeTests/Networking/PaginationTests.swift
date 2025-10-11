//
//  Test.swift
//  MobileJoe
//
//  Created by Florian on 07.07.25.
//

import Testing
import Foundation
@testable import MobileJoe

struct PaginationTest {
  @Test func `parse pagination from response headers`() async throws {
    let response = try mockURLResponse(headerFields: ["current-page": "2", "total-pages": "4"])

    let pagination = Pagination(urlResponse: response)

    #expect(pagination.currentPage == 2)
    #expect(pagination.totalPages == 4)
    #expect(pagination.hasNext)
    #expect(pagination.nextPage == 3)
  }

  @Test func `parse pagination with missing current page`() async throws {
    let response = try mockURLResponse(headerFields: ["total-pages": "4"])

    let pagination = Pagination(urlResponse: response)

    #expect(pagination.currentPage == 0)
    #expect(pagination.totalPages == 4)
    #expect(pagination.hasNext)
    #expect(pagination.nextPage == 1)
  }

  @Test func `parse pagination with missing total pages`() async throws {
    let response = try mockURLResponse(headerFields: ["current-page": "4"])

    let pagination = Pagination(urlResponse: response)

    #expect(pagination.currentPage == 4)
    #expect(pagination.totalPages == 1)
    #expect(pagination.hasNext == false)
    #expect(pagination.nextPage == nil)
  }

  @Test func `parse pagination with no headers`() async throws {
    let response = try mockURLResponse(headerFields: [:])

    let pagination = Pagination(urlResponse: response)

    #expect(pagination.currentPage == 0)
    #expect(pagination.totalPages == 1)
    // 0 < 1, so hasNext is true
    #expect(pagination.hasNext == true)
    #expect(pagination.nextPage == 1)
  }

  @Test func `hasNext is false when on last page`() async throws {
    let response = try mockURLResponse(headerFields: ["current-page": "3", "total-pages": "3"])

    let pagination = Pagination(urlResponse: response)

    #expect(pagination.currentPage == 3)
    #expect(pagination.totalPages == 3)
    #expect(pagination.hasNext == false)
    #expect(pagination.nextPage == nil)
  }

  @Test func `nextPage is correct for middle pages`() async throws {
    let response = try mockURLResponse(headerFields: ["current-page": "2", "total-pages": "5"])

    let pagination = Pagination(urlResponse: response)

    #expect(pagination.currentPage == 2)
    #expect(pagination.totalPages == 5)
    #expect(pagination.hasNext == true)
    #expect(pagination.nextPage == 3)
  }

  @Test func `handles negative page number`() async throws {
    let response = try mockURLResponse(headerFields: ["current-page": "-1", "total-pages": "5"])

    let pagination = Pagination(urlResponse: response)

    // "-1" successfully converts to Int(-1)
    #expect(pagination.currentPage == -1)
    #expect(pagination.totalPages == 5)
  }

  @Test(arguments: ["abc", "9999999999999999999", "1.5", ""])
  func `handles non-numeric page values`(invalidValue: String) async throws {
    let response = try mockURLResponse(headerFields: ["current-page": invalidValue, "total-pages": "5"])

    let pagination = Pagination(urlResponse: response)

    // Invalid strings fail to convert, so defaults are used
    #expect(pagination.currentPage == 0)
    #expect(pagination.totalPages == 5)
  }

  @Test func `handles zero as page number`() async throws {
    let response = try mockURLResponse(headerFields: ["current-page": "0", "total-pages": "5"])

    let pagination = Pagination(urlResponse: response)

    #expect(pagination.currentPage == 0)
    #expect(pagination.totalPages == 5)
    #expect(pagination.hasNext == true)
    #expect(pagination.nextPage == 1)
  }
}

extension PaginationTest {
  private func mockURLResponse(headerFields: [String: String]) throws -> HTTPURLResponse {
    let url = try #require(URL(string: "https://mbj-api.com"))
    return try #require(
      HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headerFields)
    )
  }
}

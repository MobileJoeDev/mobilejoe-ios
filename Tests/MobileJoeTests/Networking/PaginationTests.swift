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
}

extension PaginationTest {
  private func mockURLResponse(headerFields: [String: String]) throws -> HTTPURLResponse {
    let url = try #require(URL(string: "https://mbj-api.com"))
    return try #require(
      HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headerFields)
    )
  }
}

// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

struct Pagination: Equatable {
  let currentPage: Int
  let totalPages: Int
  let totalCount: Int

  var nextPage: Int? {
    guard hasNext else { return nil }
    return currentPage + 1
  }

  var hasNext: Bool {
    currentPage < totalPages
  }

  init() {
    self.currentPage = 0
    self.totalPages = 1
    self.totalCount = 1
  }

  init(currentPage: Int, totalPages: Int, totalCount: Int) {
    self.currentPage = currentPage
    self.totalPages = totalPages
    self.totalCount = totalCount
  }

  init(urlResponse: HTTPURLResponse) {
    self.totalPages = Pagination.value(for: "total-pages", from: urlResponse) ?? 1
    self.currentPage = Pagination.value(for: "current-page", from: urlResponse) ?? 0
    self.totalCount = Pagination.value(for: "total-count", from: urlResponse) ?? 0
  }
}

extension Pagination {
  private static func value(for field: String, from urlResponse: HTTPURLResponse) -> Int? {
    guard let value = urlResponse.value(forHTTPHeaderField: field) else { return nil }
    return Int(value)
  }
}

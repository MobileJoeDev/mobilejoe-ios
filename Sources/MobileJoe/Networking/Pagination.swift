//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Pagination.swift
//
//  Created by Florian on 07.07.25.
//

import Foundation

struct Pagination: Equatable, Sendable {
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

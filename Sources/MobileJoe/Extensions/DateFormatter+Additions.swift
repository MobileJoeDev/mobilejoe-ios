//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 20.03.25.
//

import Foundation

extension DateFormatter {
  static let apiDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    f.timeZone = .utc
    return f
  }()
}

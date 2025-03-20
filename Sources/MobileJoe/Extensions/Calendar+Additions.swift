//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 20.03.25.
//

import Foundation

extension Calendar {
  static let utc: Calendar = {
    var calendar = Calendar.current
    calendar.timeZone = .utc
    return calendar
  }()

  func date(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date? {
    date(from: .init(year: year, month: month, day: day, hour: hour, minute: minute, second: second))
  }
}

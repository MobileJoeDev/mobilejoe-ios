//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Calendar+Additions.swift
//
//  Created by Florian Mielke on 20.03.25.
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

// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

extension Calendar {
  package static let utc: Calendar = {
    var calendar = Calendar.current
    calendar.timeZone = .utc
    return calendar
  }()

  package func date(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date? {
    date(from: .init(year: year, month: month, day: day, hour: hour, minute: minute, second: second))
  }
}

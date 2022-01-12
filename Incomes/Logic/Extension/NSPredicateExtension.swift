//
//  NSPredicateExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

extension NSPredicate {
    convenience init(dateIsBetween start: Date, and end: Date) {
        self.init(format: "date BETWEEN {%@, %@}",
                  start.nsValue,
                  end.nsValue)
    }

    convenience init(dateIsSameMonthAs date: Date) {
        self.init(dateIsBetween: Calendar.current.startOfMonth(for: date),
                  and: Calendar.current.endOfMonth(for: date))
    }

    convenience init(dateIsAfter date: Date) {
        self.init(format: "date >= %@", date.nsValue)
    }

    convenience init(contentIs content: String) {
        self.init(format: "content == %@", content)
    }

    convenience init(groupIs group: String) {
        self.init(format: "group == %@", group)
    }

    convenience init(repeatIDIs repeatID: UUID) {
        self.init(format: "repeatID = %@",
                  repeatID.nsValue)
    }

    convenience init(repeatIDIs repeatID: UUID, dateIsAfter date: Date) {
        self.init(format: "(repeatID = %@) AND (date >= %@)",
                  repeatID.nsValue,
                  date.nsValue)
    }

    convenience init(yearIs year: String) {
        self.init(format: "year == %@", year)
    }
}

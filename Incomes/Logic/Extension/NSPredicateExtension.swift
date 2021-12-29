//
//  NSPredicateExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

extension NSPredicate {
    convenience init(dateBetween start: Date, and end: Date) {
        self.init(format: "date BETWEEN {%@, %@}",
                  start.nsValue,
                  end.nsValue)
    }

    convenience init(dateBetweenMonthFor date: Date) {
        self.init(dateBetween: Calendar.current.startOfMonth(for: date),
                  and: Calendar.current.endOfMonth(for: date))
    }

    convenience init(group: String) {
        self.init(format: "group == %@", group)
    }
}

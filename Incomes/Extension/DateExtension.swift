//
//  DateExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Date {
    var year: String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "y", options: 0, locale: .current)
        return formatter.string(from: self)
    }

    var yearAndMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yM", options: 0, locale: .current)
        return formatter.string(from: self)
    }

    var monthAndDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: .current)
        return formatter.string(from: self)
    }

    var yearAndMonthAndDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMd", options: 0, locale: .current)
        return formatter.string(from: self)
    }
}

//
//  DateExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Date {
    enum Template: String {
        case yyyy
        case yyyyMMM
        case MMMd
        case yyyyMMMd
    }

    private static let formatter = DateFormatter()

    var nsValue: NSDate {
        NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
    }

    func stringValue(_ template: Template, locale: Locale = .current) -> String {
        Self.formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue,
                                                             options: 0,
                                                             locale: locale)
        return Self.formatter.string(from: self)
    }
}

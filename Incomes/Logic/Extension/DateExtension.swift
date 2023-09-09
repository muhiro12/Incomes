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
        case yyyyMM
        case yyyyMMM
        case MMMd
        case yyyyMMMd
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .init(secondsFromGMT: .zero)
        return formatter
    }()

    func stringValue(_ template: Template, locale: Locale = .current) -> String {
        Self.formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue,
                                                             options: .zero,
                                                             locale: locale)
        return Self.formatter.string(from: self)
    }

    func stringValueWithoutLocale(_ template: Date.Template) -> String {
        Self.formatter.dateFormat = template.rawValue
        return Self.formatter.string(from: self)
    }
}

//
//  DateFormatterExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/26.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation

extension DateFormatter {
    enum Template: String {
        case yyyy
        case yyyyMM
        case yyyyMMM
        case MMMd
        case yyyyMMMd
    }

    private static let defaultFormatter = DateFormatter()

    private static let fixedFormatFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .gmt
        return formatter
    }()

    static func `default`(_ template: Template, locale: Locale) -> DateFormatter {
        let formatter = defaultFormatter
        formatter.dateFormat = dateFormat(
            fromTemplate: template.rawValue,
            options: .zero,
            locale: locale
        )
        return formatter
    }

    static func fixed(_ template: Template) -> DateFormatter {
        let formatter = fixedFormatFormatter
        formatter.dateFormat = template.rawValue
        return formatter
    }
}

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

    private static let `default`: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .init(secondsFromGMT: .zero)
        return formatter
    }()

    static func formatter(_ template: Template, locale: Locale = .current) -> DateFormatter {
        let formatter = Self.default
        formatter.dateFormat = dateFormat(fromTemplate: template.rawValue,
                                          options: .zero,
                                          locale: locale)
        return formatter
    }

    static func formatterWithoutLocale(_ template: Template) -> DateFormatter {
        let formatter = Self.default
        formatter.dateFormat = template.rawValue
        return formatter
    }
}

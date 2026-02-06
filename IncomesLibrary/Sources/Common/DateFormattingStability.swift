//
//  DateFormattingStability.swift
//  Incomes
//
//  Created by Codex on 2026/02/06.
//

import Foundation

public nonisolated extension DateFormatter {
    static func stableDefault(_ template: Template, locale: Locale) -> DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = dateFormat(
            fromTemplate: template.rawValue,
            options: .zero,
            locale: locale
        )
        formatter.locale = locale
        return formatter
    }

    static func stableFixed(_ template: Template) -> DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = template.rawValue
        formatter.locale = .init(identifier: "en_US_POSIX")
        return formatter
    }
}

public nonisolated extension String {
    func stableDateValueWithoutLocale(_ template: DateFormatter.Template) -> Date? {
        DateFormatter.stableFixed(template).date(from: self)
    }
}

public nonisolated extension Date {
    func stableStringValue(_ template: DateFormatter.Template, locale: Locale = .current) -> String {
        DateFormatter.stableDefault(template, locale: locale).string(from: self)
    }

    func stableStringValueWithoutLocale(_ template: DateFormatter.Template) -> String {
        DateFormatter.stableFixed(template).string(from: self)
    }
}

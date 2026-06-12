import Foundation // swiftlint:disable:this file_name

public extension DateFormatter {
    /// A small set of date format templates used across Incomes.
    enum Template: String {
        case yyyy
        case yyyyMM
        case yyyyMMM
        case MMMd
        case yyyyMMdd
        case yyyyMMMd
    }

    /// Returns a locale-aware formatter derived from the given template.
    static func `default`(_ template: Template, locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat(
            fromTemplate: template.rawValue,
            options: .zero,
            locale: locale
        )
        formatter.locale = locale
        return formatter
    }

    /// Returns a locale-independent formatter using the template as a fixed date format.
    /// The time zone intentionally follows Foundation's default time zone so
    /// date-only user values continue to follow the app's current calendar day.
    static func fixed(_ template: Template) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = template.rawValue
        formatter.locale = .init(identifier: "en_US_POSIX")
        return formatter
    }
}

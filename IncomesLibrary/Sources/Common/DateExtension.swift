import Foundation // swiftlint:disable:this file_name

public extension Date {
    /// Formats the date using a locale-aware formatter derived from the given template.
    func stringValue(_ template: DateFormatter.Template, locale: Locale = .current) -> String {
        DateFormatter.default(template, locale: locale).string(from: self)
    }

    /// Formats the date using a fixed, locale-independent formatter.
    func stringValueWithoutLocale(_ template: DateFormatter.Template) -> String {
        DateFormatter.fixed(template).string(from: self)
    }
}

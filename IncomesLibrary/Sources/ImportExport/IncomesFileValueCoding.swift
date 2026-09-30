import Foundation
import SwiftData

/// Text representations of dates, amounts, and versions shared by every file version.
enum IncomesFileValueCoding {
    private static let posixLocale = Locale(identifier: "en_US_POSIX")

    /// Formats a stored UTC day as Gregorian `yyyy-MM-dd`.
    static func dayString(from date: Date) -> String {
        dayFormatter().string(from: date)
    }

    /// Parses a strict `yyyy-MM-dd` day, rejecting impossible dates such as `2026-02-30`.
    static func day(from text: String) -> Date? {
        let formatter = dayFormatter()
        guard let date = formatter.date(from: text),
              formatter.string(from: date) == text else {
            return nil
        }
        return date
    }

    /// Formats an amount exactly, with a period separator and no grouping.
    static func amountString(from value: Decimal) -> String {
        var value = value
        return NSDecimalString(&value, posixLocale)
    }

    /// Parses a plain decimal amount that the store can keep exactly.
    static func amount(from text: String) -> Decimal? {
        let unsignedText = text.hasPrefix("-") ? text.dropFirst() : Substring(text)
        // One split leaves any second separator inside the fraction, where it fails the digit check.
        let components = unsignedText.split(
            separator: ".",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )
        let hasOnlyDigits = components.allSatisfy { component in
            !component.isEmpty && component.allSatisfy { character in
                character.isASCII && character.isNumber
            }
        }
        guard hasOnlyDigits,
              AmountPrecision.significantDigitCount(in: text) <= AmountPrecision.maximumSignificantDigits,
              let value = Decimal(string: text, locale: posixLocale),
              AmountPrecision.isExactlyStorable(value) else {
            return nil
        }
        return value
    }

    /// Formats a moment as an ISO 8601 UTC timestamp with second precision.
    static func timestampString(from date: Date) -> String {
        date.formatted(.iso8601)
    }

    /// Parses an ISO 8601 timestamp.
    static func timestamp(from text: String) -> Date? {
        try? Date(text, strategy: .iso8601)
    }

    /// Formats a schema version as `major.minor.patch`.
    static func versionString(from version: Schema.Version) -> String {
        "\(version.major).\(version.minor).\(version.patch)"
    }

    /// Parses a strict `major.minor.patch` schema version.
    static func version(from text: String) -> Schema.Version? {
        let components = text.split(
            separator: ".",
            omittingEmptySubsequences: false
        )
        let numbers = components.compactMap { component -> Int? in
            guard !component.isEmpty,
                  component.allSatisfy({ character in
                    character.isASCII && character.isNumber
                  }) else {
                return nil
            }
            return Int(component)
        }
        var iterator = numbers.makeIterator()
        guard numbers.count == components.count,
              let major = iterator.next(),
              let minor = iterator.next(),
              let patch = iterator.next(),
              iterator.next() == nil else {
            return nil
        }
        return .init(major, minor, patch)
    }
}

private extension IncomesFileValueCoding {
    static func dayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = posixLocale
        formatter.calendar = .utc
        formatter.timeZone = .init(secondsFromGMT: .zero)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        return formatter
    }
}

import Foundation

/// Small date string formatting utilities.
public enum Formatting {
    /// Formats a month title like "2025 Sep" for the provided date.
    public static func monthTitle(from date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "yyyy MMM"
        return formatter.string(from: date)
    }

    /// Formats a short day title like "Sep 12 (Fri)".
    public static func shortDayTitle(from date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "MMM d (EEE)"
        return formatter.string(from: date)
    }
}

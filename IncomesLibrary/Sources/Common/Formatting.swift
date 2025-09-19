import Foundation

public enum Formatting {
    public static func monthTitle(from date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "yyyy MMM"
        return formatter.string(from: date)
    }

    public static func shortDayTitle(from date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "MMM d (EEE)"
        return formatter.string(from: date)
    }
}

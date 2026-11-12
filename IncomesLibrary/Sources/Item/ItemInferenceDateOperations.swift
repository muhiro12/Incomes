import Foundation

/// Resolves source-backed date expressions without asking a model to calculate calendar days.
public enum ItemInferenceDateOperations {
    private static let maximumExpressionLength = 80
    private static let maximumYear = 9_999
    private static let twoDayOffset = 2
    private static let relativeDays = [
        "today": 0, "今日": 0, "本日": 0, "hoy": 0, "aujourd'hui": 0, "aujourd’hui": 0, "今天": 0,
        "yesterday": -1, "昨日": -1, "ayer": -1, "hier": -1, "昨天": -1,
        "tomorrow": 1, "明日": 1, "mañana": 1, "demain": 1, "明天": 1,
        "the day before yesterday": -twoDayOffset, "一昨日": -twoDayOffset,
        "anteayer": -twoDayOffset, "avant-hier": -twoDayOffset, "前天": -twoDayOffset,
        "the day after tomorrow": twoDayOffset, "明後日": twoDayOffset,
        "pasado mañana": twoDayOffset, "après-demain": twoDayOffset, "后天": twoDayOffset
    ]

    /// Returns a canonical Gregorian day, or empty text when the expression cannot identify one source-backed day.
    public static func dateString(
        expression: String,
        sourceText: String,
        referenceDate: Date,
        locale: Locale,
        timeZone: TimeZone = .current
    ) -> String {
        let expression = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !expression.isEmpty, expression.count <= maximumExpressionLength,
              sourceText.contains(expression) else {
            return ""
        }
        var normalized = expression.folding(options: [.caseInsensitive, .widthInsensitive], locale: locale)
        // Japanese case particles do not change the day denoted by the copied phrase.
        if normalized.hasSuffix("の") || normalized.hasSuffix("に") {
            normalized.removeLast()
            normalized = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let date: Date?
        if let offset = relativeDays[normalized] {
            date = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: referenceDate))
        } else {
            date = numericDate(normalized, referenceDate: referenceDate, calendar: calendar)
                ?? writtenDate(normalized, locale: locale, calendar: calendar)
        }
        guard let date, (1...maximumYear).contains(calendar.component(.year, from: date)) else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
}

private extension ItemInferenceDateOperations {
    static func numericDate(_ expression: String, referenceDate: Date, calendar: Calendar) -> Date? {
        let pattern = #"^(?:(?<year>[0-9]{4})[-/.年])?(?<month>[0-9]{1,2})[-/.月](?<day>[0-9]{1,2})日?$"#
        guard let regularExpression = try? NSRegularExpression(pattern: pattern),
              let match = regularExpression.firstMatch(
                in: expression, range: NSRange(expression.startIndex..., in: expression)
              ) else {
            return nil
        }
        let values = ["year", "month", "day"].reduce(into: [String: Int]()) { values, name in
            if let range = Range(match.range(withName: name), in: expression) {
                values[name] = Int(expression[range])
            }
        }
        guard values["year"] != nil || expression.contains("月"),
              let month = values["month"], let day = values["day"] else {
            return nil
        }
        let year = values["year"] ?? calendar.component(.year, from: referenceDate)
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components),
              calendar.component(.year, from: date) == year,
              calendar.component(.month, from: date) == month,
              calendar.component(.day, from: date) == day else {
            return nil
        }
        return date
    }

    static func writtenDate(_ expression: String, locale: Locale, calendar: Calendar) -> Date? {
        let formats = ["MMMM d, yyyy", "MMM d, yyyy", "d MMMM yyyy", "d MMM yyyy", "d 'de' MMMM 'de' yyyy"]
        let locales = [
            locale, Locale(identifier: "en_US_POSIX"), .init(identifier: "fr_FR"), .init(identifier: "es_ES")
        ]
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.isLenient = false
        for locale in locales {
            formatter.locale = locale
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: expression),
                   formatter.string(from: date).folding(options: .caseInsensitive, locale: locale) == expression {
                    return date
                }
            }
        }
        return nil
    }
}

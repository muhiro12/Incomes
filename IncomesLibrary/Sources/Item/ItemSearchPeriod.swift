import Foundation

/// One Gregorian calendar month used as an item search period.
public struct ItemSearchPeriod: Hashable, Sendable {
    /// Gregorian year.
    public let year: Int
    /// Month number from 1 through 12.
    public let month: Int

    /// Creates a period for a valid Gregorian year and month.
    public init?(year: Int, month: Int) {
        guard NaturalLanguageSearchValidator.supportedYears.contains(year),
              NaturalLanguageSearchValidator.supportedMonths.contains(month) else {
            return nil
        }
        self.year = year
        self.month = month
    }

    /// First and last local days of the month for display in `calendar`.
    public func displayDays(
        in calendar: Calendar = .current
    ) -> (first: Date, last: Date)? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        guard let first = gregorian.date(
            from: .init(year: year, month: month, day: 1)
        ),
        let dayRange = gregorian.range(of: .day, in: .month, for: first),
        let last = gregorian.date(
            from: .init(year: year, month: month, day: dayRange.count)
        ) else {
            return nil
        }
        return (first, last)
    }
}

extension ItemSearchPeriod {
    /// Stored-date bounds matching the UTC-shifted representation used by `Item.date`.
    var storedDateBounds: (start: Date, end: Date)? {
        guard let start = Calendar.utc.date(
            from: .init(year: year, month: month, day: 1)
        ) else {
            return nil
        }
        return (start, Calendar.utc.endOfMonth(for: start))
    }
}

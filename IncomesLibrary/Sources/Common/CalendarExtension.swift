import Foundation // swiftlint:disable:this file_name

extension Calendar {
    /// A Gregorian calendar fixed to the UTC time zone.
    static var utc: Self {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .init(secondsFromGMT: .zero) ?? .current
        return calendar
    }

    /// Returns the last moment of the day that contains the given date.
    func endOfDay(for date: Date) -> Date {
        guard let next = self.date(byAdding: .day, value: 1, to: date) else {
            assertionFailure()
            return date
        }
        return startOfDay(for: next) - 1
    }

    /// Returns the first moment of the month that contains the given date.
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        guard let start = self.date(from: components) else {
            assertionFailure()
            return date
        }
        return start
    }

    /// Returns the last moment of the month that contains the given date.
    func endOfMonth(for date: Date) -> Date {
        guard let next = self.date(byAdding: .month, value: 1, to: date) else {
            assertionFailure()
            return date
        }
        return startOfMonth(for: next) - 1
    }

    /// Returns the first moment of the year that contains the given date.
    func startOfYear(for date: Date) -> Date {
        let components = dateComponents([.year], from: date)
        guard let start = self.date(from: components) else {
            assertionFailure()
            return date
        }
        return start
    }

    /// Returns the last moment of the year that contains the given date.
    func endOfYear(for date: Date) -> Date {
        guard let next = self.date(byAdding: .year, value: 1, to: date) else {
            assertionFailure()
            return date
        }
        return startOfYear(for: next) - 1
    }

    /// Creates a date in this calendar by copying date-time components from another calendar.
    func shiftedDate(componentsFrom date: Date, in calendar: Calendar) -> Date {
        let shifted = self.date(
            from: calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: date
            )
        )
        guard let shifted else {
            assertionFailure("Failed to shift date components from \(calendar) to \(self) for date: \(date)")
            return date
        }
        return shifted
    }
}

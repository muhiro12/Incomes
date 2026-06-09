import Foundation

/// Resolves the initial item form date from a tag context.
public enum ItemFormInitialDateResolver {
    /// Returns the date that should initialize the form for `tag`.
    public static func date(
        for tag: Tag,
        currentDate: Date
    ) -> Date {
        date(for: tag, currentDate: currentDate, calendar: .current)
    }

    static func date(
        for tag: Tag,
        currentDate: Date,
        calendar: Calendar
    ) -> Date {
        switch tag.type {
        case .year:
            return yearDate(for: tag, currentDate: currentDate, calendar: calendar)
        case .yearMonth:
            return yearMonthDate(for: tag, currentDate: currentDate, calendar: calendar)
        case .content, .category, .debug, .none:
            return currentDate
        }
    }
}

private extension ItemFormInitialDateResolver {
    static func yearDate(
        for tag: Tag,
        currentDate: Date,
        calendar: Calendar
    ) -> Date {
        guard let tagDate = TagQueryOperations.date(for: tag) else {
            return currentDate
        }

        let tagYear = calendar.component(.year, from: tagDate)
        let currentYear = calendar.component(.year, from: currentDate)
        if tagYear == currentYear {
            return currentDate
        }
        return tagDate
    }

    static func yearMonthDate(
        for tag: Tag,
        currentDate: Date,
        calendar: Calendar
    ) -> Date {
        guard let tagDate = TagQueryOperations.date(for: tag) else {
            return currentDate
        }

        let tagComponents = calendar.dateComponents([.year, .month], from: tagDate)
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        if tagComponents.year == currentComponents.year,
           tagComponents.month == currentComponents.month {
            return currentDate
        }
        return tagDate
    }
}

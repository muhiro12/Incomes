import Foundation
import SwiftData

/// Loads the default year and month selections for main navigation.
public enum MainNavigationStateLoader {
    /// Returns the year and year-month tags that match `date`.
    public static func load(
        context: ModelContext,
        date: Date = .now
    ) throws -> MainNavigationState {
        let yearTag = try TagService.getByName(
            context: context,
            name: date.stringValueWithoutLocale(.yyyy),
            type: .year
        )
        let yearMonthTag = try TagService.getByName(
            context: context,
            name: date.stringValueWithoutLocale(.yyyyMM),
            type: .yearMonth
        )
        return .init(
            yearTag: yearTag,
            yearMonthTag: yearMonthTag
        )
    }
}

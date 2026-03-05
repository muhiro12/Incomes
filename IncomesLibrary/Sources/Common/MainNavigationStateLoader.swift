import Foundation
import SwiftData

/// Documented for SwiftLint compliance.
public enum MainNavigationStateLoader {
    /// Documented for SwiftLint compliance.
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

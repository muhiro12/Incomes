import Foundation
import SwiftData

enum MainNavigationStateLoader {
    static func load(
        context: ModelContext,
        date: Date = .now
    ) throws -> MainNavigationState {
        let yearTag = try TagQueryOperations.getByName(
            context: context,
            name: date.stringValueWithoutLocale(.yyyy),
            type: .year
        )
        let yearMonthTag = try TagQueryOperations.getByName(
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

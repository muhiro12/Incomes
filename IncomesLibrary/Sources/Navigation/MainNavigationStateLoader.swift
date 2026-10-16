import Foundation
import SwiftData

enum MainNavigationStateLoader {
    static func load(
        context: ModelContext,
        date: Date = .now,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> MainNavigationState {
        let yearTag = try TagQueryOperations.getByName(
            context: context,
            name: date.stringValueWithoutLocale(.yyyy),
            type: .year,
            ledgerIdentifier: ledgerIdentifier
        )
        let yearMonthTag = try TagQueryOperations.getByName(
            context: context,
            name: date.stringValueWithoutLocale(.yyyyMM),
            type: .yearMonth,
            ledgerIdentifier: ledgerIdentifier
        )
        return .init(
            yearTag: yearTag,
            yearMonthTag: yearMonthTag
        )
    }
}

import Foundation
import SwiftData

enum ItemIntentGetValueSupport {
    static func entities(
        context: ModelContext,
        date: Date
    ) throws -> [ItemEntity] {
        let items = try ItemQueryOperations.items(
            context: context,
            date: date
        )
        return try ItemIntentEntitySupport.entities(from: items)
    }

    static func allItemsCount(context: ModelContext) throws -> Int {
        try ItemQueryOperations.allItemsCount(context: context)
    }

    static func yearItemsCount(
        context: ModelContext,
        date: Date
    ) throws -> Int {
        try ItemQueryOperations.yearItemsCount(
            context: context,
            date: date
        )
    }

    static func repeatItemsCount(
        context: ModelContext,
        repeatID: UUID
    ) throws -> Int {
        try ItemQueryOperations.repeatItemsCount(
            context: context,
            repeatID: repeatID
        )
    }

    @available(iOS 26.0, *)
    static func monthlySummary(
        context: ModelContext,
        date: Date,
        locale: Locale
    ) async throws -> String {
        try await MonthlySummaryGenerator.generate(
            context: context,
            date: date,
            currencyCode: IncomesCurrencyPreference.preferredCurrencyCode(),
            locale: locale
        )
    }
}

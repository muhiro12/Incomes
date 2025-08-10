import AppIntents
import Foundation
import FoundationModels
import SwiftData
import SwiftUI

@MainActor
enum ItemService {
    static func create(
        context: ModelContext,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        repeatCount: Int
    ) throws -> Item {
        var items = [Item]()
        let repeatID = UUID()
        let item = try Item.create(
            context: context,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            repeatID: repeatID
        )
        items.append(item)
        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let repeatingDate = Calendar.current.date(byAdding: .month, value: index, to: date) else {
                assertionFailure()
                continue
            }
            let item = try Item.create(
                context: context,
                date: repeatingDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                repeatID: repeatID
            )
            items.append(item)
        }
        items.forEach(context.insert)
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: items)
        return item
    }

    @available(iOS 26.0, *)
    static func inferForm(text: String) async throws -> ItemFormInference {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let today = formatter.string(from: Date())
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let session = LanguageModelSession(
            instructions: """
                You are a professional financial advisor for a household accounting and budgeting app. Carefully extract and output the necessary fields from user input as an expert accountant.
                Always provide reliable and precise results.
                """
        )
        let prompt = """
            Today's date is: \(today)
            You are a professional financial advisor for a household accounting and budgeting app. Carefully extract and output the following fields from the user input:
            - date (yyyyMMdd) (If the date in the text is relative, such as 'last month' or 'next month', convert it to the correct date)
            - content (description)
            - income
            - outgo
            - category

            REQUIREMENT:
            - Respond ONLY with the values in the language: \(languageCode).
            - Never reply in English unless the device language is English.
            - All field values must be in the device's language, matching the user's input language.
            - If the language is Japanese, return all labels and values in Japanese, and treat relative time expressions (like '来月', '先月') accurately.
            - Output only the result values, no explanation, format, or extra words.

            Text: \(text)
            """
        let response = try await session.respond(
            to: prompt,
            generating: ItemFormInference.self
        )
        return response.content
    }

    static func delete(context: ModelContext, item: Item) throws {
        item.delete()
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: [item])
    }

    static func deleteAll(context: ModelContext) throws {
        let items = try context.fetch(FetchDescriptor<Item>())
        items.forEach { item in
            item.delete()
        }
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: items)
    }

    static func allItemsCount(context: ModelContext) throws -> Int {
        try context.fetchCount(.items(.all))
    }

    static func repeatItemsCount(context: ModelContext, repeatID: UUID) throws -> Int {
        try context.fetchCount(.items(.repeatIDIs(repeatID)))
    }

    static func yearItemsCount(context: ModelContext, date: Date) throws -> Int {
        try context.fetchCount(.items(.dateIsSameYearAs(date)))
    }

    static func items(context: ModelContext, date: Date) throws -> [Item] {
        try context.fetch(
            .items(.dateIsSameMonthAs(date))
        )
    }

    private static func nextItemModel(
        context: ModelContext,
        date: Date
    ) throws -> Item? {
        let descriptor = FetchDescriptor.items(
            .dateIsAfter(date),
            order: .forward
        )
        return try context.fetchFirst(descriptor)
    }

    private static func previousItemModel(
        context: ModelContext,
        date: Date
    ) throws -> Item? {
        let descriptor = FetchDescriptor.items(.dateIsBefore(date))
        return try context.fetchFirst(descriptor)
    }

    static func nextItem(context: ModelContext, date: Date) throws -> Item? {
        try nextItemModel(context: context, date: date)
    }

    static func previousItem(context: ModelContext, date: Date) throws -> Item? {
        try previousItemModel(context: context, date: date)
    }

    static func nextItems(context: ModelContext, date: Date) throws -> [Item] {
        guard let item = try nextItemModel(context: context, date: date) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate))
        )
    }

    static func previousItems(context: ModelContext, date: Date) throws -> [Item] {
        guard let item = try previousItemModel(context: context, date: date) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate))
        )
    }

    static func nextItemDate(context: ModelContext, date: Date) throws -> Date? {
        try nextItemModel(context: context, date: date)?.localDate
    }

    static func previousItemDate(context: ModelContext, date: Date) throws -> Date? {
        try previousItemModel(context: context, date: date)?.localDate
    }

    static func nextItemContent(context: ModelContext, date: Date) throws -> String? {
        try nextItemModel(context: context, date: date)?.content
    }

    static func previousItemContent(context: ModelContext, date: Date) throws -> String? {
        try previousItemModel(context: context, date: date)?.content
    }

    static func nextItemProfit(context: ModelContext, date: Date) throws -> IntentCurrencyAmount? {
        guard let profit = try nextItemModel(context: context, date: date)?.profit else {
            return nil
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .init(amount: profit, currencyCode: currencyCode)
    }

    static func previousItemProfit(context: ModelContext, date: Date) throws -> IntentCurrencyAmount? {
        guard let profit = try previousItemModel(context: context, date: date)?.profit else {
            return nil
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .init(amount: profit, currencyCode: currencyCode)
    }

    static func update(
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) throws {
        try item.modify(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            repeatID: .init()
        )
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: [item])
    }

    static func updateRepeatingItems(
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        descriptor: FetchDescriptor<Item>
    ) throws {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: item.date,
            to: date
        )
        let repeatID = UUID()
        let items = try context.fetch(descriptor)
        try items.forEach { item in
            guard let newDate = Calendar.current.date(byAdding: components, to: item.localDate) else {
                assertionFailure()
                return
            }
            try item.modify(
                date: newDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                repeatID: repeatID
            )
        }
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: items)
    }

    static func updateAll(
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) throws {
        try updateRepeatingItems(
            context: context,
            item: item,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            descriptor: .items(.repeatIDIs(item.repeatID))
        )
    }

    static func updateFuture(
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) throws {
        try updateRepeatingItems(
            context: context,
            item: item,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            descriptor: .items(
                .repeatIDAndDateIsAfter(
                    repeatID: item.repeatID,
                    date: item.localDate
                )
            )
        )
    }

    static func recalculate(context: ModelContext, date: Date) throws {
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, after: date)
    }
}

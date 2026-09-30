import Foundation
import SwiftData

// swiftlint:disable no_magic_numbers

/// Seeds the sample-data profiles that `SampleDataOperations` exposes.
enum ItemSampleDataSeeder {
    static func seed(
        context: ModelContext,
        profile: SampleDataOperations.Profile,
        baseDate: Date,
        locale: Locale,
        ifEmptyOnly: Bool
    ) throws {
        if ifEmptyOnly {
            let count = try ItemQueryOperations.allItemsCount(context: context)
            guard count == .zero else {
                return
            }
        }

        switch profile {
        case .minimal:
            try seedMinimalData(context: context, baseDate: baseDate, locale: locale)
        case .standard:
            _ = try seedLedger(
                context: context,
                baseDate: baseDate,
                locale: locale,
                monthOffsets: standardMonthOffsets()
            )
        case .largeLedger:
            _ = try seedLedger(
                context: context,
                baseDate: baseDate,
                locale: locale,
                monthOffsets: largeLedgerMonthOffsets()
            )
        case .duplicateTags:
            let items = try seedLedger(
                context: context,
                baseDate: baseDate,
                locale: locale,
                monthOffsets: standardMonthOffsets()
            )
            duplicateTags(of: items, context: context)
        case .largeAmounts:
            try seedLargeAmountData(context: context, baseDate: baseDate)
        case .inexactTotals:
            try seedInexactTotalData(context: context, baseDate: baseDate)
        }
    }

    /// Seeds the monthly templates for each month offset from the start of
    /// `baseDate`'s year, after an opening payday in the preceding month.
    static func seedLedger(
        context: ModelContext,
        baseDate: Date,
        locale: Locale,
        monthOffsets: Range<Int>
    ) throws -> [Item] {
        guard let daySet = LedgerDaySet(baseDate: baseDate) else {
            return []
        }

        let openingPayday = try createLedgerItem(
            context: context,
            daySet: daySet,
            monthOffset: monthOffsets.lowerBound - 1,
            template: paydayTemplate(),
            locale: locale
        )
        let monthlyItems = try monthOffsets.flatMap { monthOffset in
            try ledgerItemTemplates().map { template in
                try createLedgerItem(
                    context: context,
                    daySet: daySet,
                    monthOffset: monthOffset,
                    template: template,
                    locale: locale
                )
            }
        }
        let created = [openingPayday] + monthlyItems

        try BalanceCalculator.calculate(in: context, for: created)
        try created.forEach { item in
            try attachSampleTag(to: item, context: context)
        }
        return created
    }

    /// Seeds three items over the two days before `baseDate`.
    static func seedMinimalData(
        context: ModelContext,
        baseDate: Date,
        locale: Locale
    ) throws {
        let firstDate = baseDate
        let secondDate = Calendar.current.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate
        let thirdDate = Calendar.current.date(
            byAdding: .day,
            value: -2,
            to: baseDate
        ) ?? baseDate

        let incomeItem = try Item.create(
            context: context,
            values: .init(
                date: firstDate,
                content: String(localized: "Salary", table: "SampleData", bundle: .module),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 3_000, locale: locale),
                outgo: .zero,
                category: String(localized: "Salary", table: "SampleData", bundle: .module),
                priority: 0
            ),
            repeatID: .init()
        )
        try attachSampleTag(to: incomeItem, context: context)

        let rentItem = try Item.create(
            context: context,
            values: .init(
                date: secondDate,
                content: String(localized: "Rent", table: "SampleData", bundle: .module),
                income: .zero,
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_200, locale: locale),
                category: String(localized: "Housing", table: "SampleData", bundle: .module),
                priority: 0
            ),
            repeatID: .init()
        )
        try attachSampleTag(to: rentItem, context: context)

        let groceryItem = try Item.create(
            context: context,
            values: .init(
                date: thirdDate,
                content: String(localized: "Grocery", table: "SampleData", bundle: .module),
                income: .zero,
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 45, locale: locale),
                category: String(localized: "Food", table: "SampleData", bundle: .module),
                priority: 0
            ),
            repeatID: .init()
        )
        try attachSampleTag(to: groceryItem, context: context)

        try BalanceCalculator.calculate(in: context, for: [incomeItem, rentItem, groceryItem])
    }

    /// Returns whether sample data exists.
    static func hasDebugData(context: ModelContext) throws -> Bool {
        try !context.fetch(.tags(.typeIs(.debug))).isEmpty
    }

    /// Deletes items and tags associated with sample data.
    static func deleteDebugData(context: ModelContext) throws {
        let debugTags = try context.fetch(.tags(.typeIs(.debug)))
        let items = debugTags.flatMap { tag in
            tag.items ?? []
        }
        try items.forEach { item in
            try ItemDeletionOperations.delete(
                context: context,
                item: item
            )
        }
        debugTags.forEach { tag in
            TagMutationOperations.delete(tag: tag)
        }
    }
}

// swiftlint:enable no_magic_numbers

extension ItemSampleDataSeeder {
    static func attachSampleTag(to item: Item, context: ModelContext) throws {
        let sampleName = String(localized: "Sample Data", table: "SampleData", bundle: .module)
        let debugTag = try Tag.create(context: context, name: sampleName, type: .debug)
        var currentTags = item.tags ?? []
        currentTags.append(debugTag)
        item.modify(tags: currentTags)
    }
}

import Foundation
import SwiftData

/// Seeds sample datasets used by previews, tutorials, and debug tooling.
public enum ItemSampleDataSeeder { // swiftlint:disable:this type_body_length
    /// Preset datasets used when seeding sample data.
    public enum SampleDataProfile {
        /// Rich sample data used for debug flows.
        case debug
        /// Lightweight tutorial sample data.
        case tutorial
        /// Sample data used by SwiftUI previews.
        case preview
    }

    /// Seeds sample data for various profiles (debug/tutorial/preview).
    public static func seedSampleData(
        context: ModelContext,
        profile: SampleDataProfile,
        baseDate: Date = .now,
        ignoringDuplicates: Bool = false,
        ifEmptyOnly: Bool = false
    ) throws {
        if ifEmptyOnly {
            let count = try ItemOperations.allItemsCount(context: context)
            guard count == .zero else {
                return
            }
        }

        switch profile {
        case .debug:
            if ignoringDuplicates {
                try seedPreviewDataIgnoringDuplicates(context: context, baseDate: baseDate)
            } else {
                try seedPreviewData(context: context, baseDate: baseDate)
            }
        case .tutorial:
            try seedTutorialData(context: context, baseDate: baseDate)
        case .preview:
            // Use rich dataset to support various preview screens.
            try seedPreviewData(context: context, baseDate: baseDate)
        }
    }

    /// Seeds rich preview/debug data (large dataset).
    public static func seedPreviewData( // swiftlint:disable:this function_body_length
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        let startOfYear = Calendar.current.startOfYear(for: baseDate)
        guard
            let dayA = Calendar.current.date(byAdding: .day, value: 0, to: startOfYear),
            let dayB = Calendar.current.date(byAdding: .day, value: 6, to: startOfYear), // swiftlint:disable:this line_length no_magic_numbers
            let dayC = Calendar.current.date(byAdding: .day, value: 12, to: startOfYear), // swiftlint:disable:this line_length no_magic_numbers
            let dayD = Calendar.current.date(byAdding: .day, value: 18, to: startOfYear), // swiftlint:disable:this line_length no_magic_numbers
            let dayE = Calendar.current.date(byAdding: .day, value: 24, to: startOfYear) // swiftlint:disable:this line_length no_magic_numbers
        else {
            return
        }

        let monthShift: (Int, Date) -> Date = { value, date in
            Calendar.current.date(byAdding: .month, value: value, to: date) ?? date
        }

        _ = try Item.create(
            context: context,
            date: monthShift(-1, dayD),
            content: String(localized: "Payday"),
            income: LocaleAmountConverter.localizedAmount(baseUSD: 4_500), // swiftlint:disable:this no_magic_numbers
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
            category: String(localized: "Salary"),
            priority: 0,
            repeatID: .init()
        )

        var created = [Item]()
        for index in 0..<24 { // swiftlint:disable:this no_magic_numbers
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayD),
                    content: String(localized: "Payday"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 4_500), // swiftlint:disable:this line_length no_magic_numbers
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    category: String(localized: "Salary"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayD),
                    content: String(localized: "Advertising revenue"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 500), // swiftlint:disable:this line_length no_magic_numbers
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    category: String(localized: "Salary"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayB),
                    content: String(localized: "Apple card"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 900), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Credit"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayA),
                    content: String(localized: "Orange card"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 600), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Credit"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayD),
                    content: String(localized: "Lemon card"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 500), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Credit"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayE),
                    content: String(localized: "House"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_800), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Loan"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayC),
                    content: String(localized: "Car"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 300), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Loan"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayA),
                    content: String(localized: "Insurance"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 250), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Tax"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayE),
                    content: String(localized: "Pension"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 300), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Tax"),
                    priority: 0,
                    repeatID: .init()
                )
            )
        }

        try BalanceCalculator.calculate(in: context, for: created)
        try created.forEach { item in
            try attachSampleTag(to: item, context: context)
        }
    }

    /// Seeds a minimal preview dataset that ignores duplicate tag creation.
    public static func seedPreviewDataIgnoringDuplicates(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        var created = [Item]()
        for index in 0..<24 { // swiftlint:disable:this no_magic_numbers
            guard let date = Calendar.current.date(byAdding: .month, value: index, to: baseDate) else {
                continue
            }
            created.append(
                Item.createIgnoringDuplicates(
                    context: context,
                    date: date,
                    content: String(localized: "Pension"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 36), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Tax"),
                    priority: 0,
                    repeatID: .init()
                )
            )
        }
        try BalanceCalculator.calculate(in: context, for: created)
        try created.forEach { item in
            try attachSampleTag(to: item, context: context)
        }
    }

    /// Seed lightweight tutorial/debug items if the store is empty.
    public static func seedTutorialDataIfNeeded(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        try seedSampleData(
            context: context,
            profile: .tutorial,
            baseDate: baseDate,
            ignoringDuplicates: false,
            ifEmptyOnly: true
        )
    }

    /// Seed lightweight tutorial items (always, without emptiness check).
    public static func seedTutorialData(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        let firstDate = baseDate
        let secondDate = Calendar.current.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate
        let thirdDate = Calendar.current.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate // swiftlint:disable:this line_length no_magic_numbers

        let incomeItem = try Item.create(
            context: context,
            date: firstDate,
            content: String(localized: "Salary"),
            income: LocaleAmountConverter.localizedAmount(baseUSD: 3_000), // swiftlint:disable:this no_magic_numbers
            outgo: .zero,
            category: String(localized: "Salary"),
            priority: 0,
            repeatID: .init()
        )
        try attachSampleTag(to: incomeItem, context: context)

        let rentItem = try Item.create(
            context: context,
            date: secondDate,
            content: String(localized: "Rent"),
            income: .zero,
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_200), // swiftlint:disable:this no_magic_numbers
            category: String(localized: "Housing"),
            priority: 0,
            repeatID: .init()
        )
        try attachSampleTag(to: rentItem, context: context)

        let groceryItem = try Item.create(
            context: context,
            date: thirdDate,
            content: String(localized: "Grocery"),
            income: .zero,
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 45), // swiftlint:disable:this no_magic_numbers
            category: String(localized: "Food"),
            priority: 0,
            repeatID: .init()
        )
        try attachSampleTag(to: groceryItem, context: context)

        try BalanceCalculator.calculate(in: context, for: [incomeItem, rentItem, groceryItem])
    }

    /// Returns whether tutorial/debug data exists.
    public static func hasDebugData(context: ModelContext) throws -> Bool {
        try !context.fetch(.tags(.typeIs(.debug))).isEmpty
    }

    /// Deletes items and tags associated with tutorial/debug data.
    public static func deleteDebugData(context: ModelContext) throws {
        let debugTags = try context.fetch(.tags(.typeIs(.debug)))
        let items = debugTags.flatMap(\.items.orEmpty)
        try items.forEach { item in
            try ItemOperations.delete(
                context: context,
                item: item
            )
        }
        debugTags.forEach { tag in
            TagOperations.delete(tag: tag)
        }
    }
}

private extension ItemSampleDataSeeder {
    static func attachSampleTag(to item: Item, context: ModelContext) throws {
        let sampleName = String(localized: "Sample Data")
        let debugTag = try Tag.create(context: context, name: sampleName, type: .debug)
        var currentTags = item.tags.orEmpty
        currentTags.append(debugTag)
        item.modify(tags: currentTags)
    }
}

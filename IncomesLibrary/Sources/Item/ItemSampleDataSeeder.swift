import Foundation
import SwiftData

// swiftlint:disable no_magic_numbers

/// Seeds sample datasets used by previews, tutorials, and debug tooling.
enum ItemSampleDataSeeder {
    /// Preset datasets used when seeding sample data.
    enum SampleDataProfile {
        /// Rich sample data used for debug flows.
        case debug
        /// Lightweight tutorial sample data.
        case tutorial
        /// Sample data used by SwiftUI previews.
        case preview
    }

    /// Seeds sample data for various profiles (debug/tutorial/preview).
    static func seedSampleData(
        context: ModelContext,
        profile: SampleDataProfile,
        baseDate: Date = .now,
        ignoringDuplicates: Bool = false,
        ifEmptyOnly: Bool = false
    ) throws {
        if ifEmptyOnly {
            let count = try ItemQueryOperations.allItemsCount(context: context)
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
    static func seedPreviewData(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        guard let daySet = PreviewDaySet(baseDate: baseDate) else {
            return
        }

        _ = try Item.create(
            context: context,
            values: previewItemValues(
                daySet: daySet,
                monthOffset: -1,
                template: paydayTemplate()
            ),
            repeatID: .init()
        )

        let created = try previewMonthOffsets().flatMap { monthOffset in
            try previewItemTemplates().map { template in
                try createPreviewItem(
                    context: context,
                    daySet: daySet,
                    monthOffset: monthOffset,
                    template: template
                )
            }
        }

        try BalanceCalculator.calculate(in: context, for: created)
        try created.forEach { item in
            try attachSampleTag(to: item, context: context)
        }
    }

    /// Seeds a minimal preview dataset that ignores duplicate tag creation.
    static func seedPreviewDataIgnoringDuplicates(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        var created = [Item]()
        for index in 0..<24 {
            guard let date = Calendar.current.date(byAdding: .month, value: index, to: baseDate) else {
                continue
            }
            created.append(
                Item.createIgnoringDuplicates(
                    context: context,
                    values: .init(
                        date: date,
                        content: String(localized: "Pension", table: "SampleData", bundle: .module),
                        income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                        outgo: LocaleAmountConverter.localizedAmount(baseUSD: 36),
                        category: String(localized: "Tax", table: "SampleData", bundle: .module),
                        priority: 0
                    ),
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
    static func seedTutorialDataIfNeeded(
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
    static func seedTutorialData(
        context: ModelContext,
        baseDate: Date = .now
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
                income: LocaleAmountConverter.localizedAmount(baseUSD: 3_000),
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
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_200),
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
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 45),
                category: String(localized: "Food", table: "SampleData", bundle: .module),
                priority: 0
            ),
            repeatID: .init()
        )
        try attachSampleTag(to: groceryItem, context: context)

        try BalanceCalculator.calculate(in: context, for: [incomeItem, rentItem, groceryItem])
    }

    /// Returns whether tutorial/debug data exists.
    static func hasDebugData(context: ModelContext) throws -> Bool {
        try !context.fetch(.tags(.typeIs(.debug))).isEmpty
    }

    /// Deletes items and tags associated with tutorial/debug data.
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

    /// Seeds duplicate category tags for duplicate-tag previews.
    static func seedDuplicateTagPreviewData(context: ModelContext) throws {
        let previewDuplicateCount = 2
        let duplicateCategoryName = String(localized: "Credit", table: "SampleData", bundle: .module)
        let items = try ItemQueryOperations.items(context: context)
        let sourceItems = items.filter { item in
            item.category?.name == duplicateCategoryName
        }

        guard sourceItems.count >= previewDuplicateCount else {
            return
        }

        for item in sourceItems.prefix(previewDuplicateCount) {
            let duplicateTag = Tag.createIgnoringDuplicates(
                context: context,
                name: duplicateCategoryName,
                type: .category
            )
            var tags = item.tags ?? []
            tags.append(duplicateTag)
            item.modify(tags: tags)
        }
    }
}

// swiftlint:enable no_magic_numbers

private extension ItemSampleDataSeeder {
    static func attachSampleTag(to item: Item, context: ModelContext) throws {
        let sampleName = String(localized: "Sample Data", table: "SampleData", bundle: .module)
        let debugTag = try Tag.create(context: context, name: sampleName, type: .debug)
        var currentTags = item.tags ?? []
        currentTags.append(debugTag)
        item.modify(tags: currentTags)
    }
}

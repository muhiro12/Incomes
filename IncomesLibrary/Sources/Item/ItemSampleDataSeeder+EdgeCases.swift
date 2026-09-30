import Foundation
import SwiftData

// Edge-case fixtures intentionally encode the amounts that reproduce each case.
// swiftlint:disable no_magic_numbers

extension ItemSampleDataSeeder {
    /// Seeds one item per month whose amounts swing the balance across
    /// roughly ±1,000,000, independent of the current locale's currency.
    static func seedLargeAmountData(
        context: ModelContext,
        baseDate: Date
    ) throws {
        let startOfYear = Calendar.current.startOfYear(for: baseDate)
        let content = String(localized: "Sample Data", table: "SampleData", bundle: .module)
        var created = [Item]()
        for (monthOffset, amount) in largeMonthlyAmounts().enumerated() {
            guard let startOfMonth = Calendar.current.date(
                byAdding: .month,
                value: monthOffset,
                to: startOfYear
            ),
            let date = Calendar.current.date(
                byAdding: .day,
                value: 14,
                to: startOfMonth
            ) else {
                continue
            }
            let item = try Item.create(
                context: context,
                values: .init(
                    date: date,
                    content: content,
                    income: max(amount, .zero),
                    outgo: max(-amount, .zero),
                    category: content,
                    priority: 0
                ),
                repeatID: .init()
            )
            try attachSampleTag(to: item, context: context)
            created.append(item)
        }
        try BalanceCalculator.calculate(in: context, for: created)
    }

    /// Signed monthly amounts; the running balance spans about -1.75M to 1.25M.
    static func largeMonthlyAmounts() -> [Decimal] {
        [
            1_000_000,
            -250_000,
            500_000,
            -1_000_000,
            -500_000,
            -750_000,
            1_000_000,
            -250_000,
            -500_000,
            -1_000_000,
            500_000,
            -500_000
        ]
    }

    /// Seeds two items in one category whose combined amounts cannot be
    /// represented exactly. Balances stay uncalculated because they would
    /// be out of range by design.
    static func seedInexactTotalData(
        context: ModelContext,
        baseDate: Date
    ) throws {
        let content = String(localized: "Sample Data", table: "SampleData", bundle: .module)
        for amount in [Decimal(sign: .plus, exponent: 40, significand: 1), 1] {
            let item = try Item.create(
                context: context,
                values: .init(
                    date: baseDate,
                    content: content,
                    income: amount,
                    outgo: amount,
                    category: content,
                    priority: 0
                ),
                repeatID: .init()
            )
            try attachSampleTag(to: item, context: context)
        }
    }

    /// The standard ledger category whose items receive duplicate tags.
    static var duplicateTagCategoryName: String {
        String(localized: "Credit", table: "SampleData", bundle: .module)
    }

    /// Re-tags two of the given items with duplicates of their tags, so every
    /// tag type has a duplicate that items still reference. Only the given
    /// items change, so existing items in the store stay untouched.
    static func duplicateTags(of items: [Item], context: ModelContext) {
        let duplicatedItemCount = 2
        let sourceItems = items.filter { item in
            item.category?.name == duplicateTagCategoryName
        }

        for item in sourceItems.prefix(duplicatedItemCount) {
            let tags = (item.tags ?? []).map { tag in
                guard let type = tag.type,
                      type != .debug else {
                    return tag
                }
                return Tag.createIgnoringDuplicates(
                    context: context,
                    name: tag.name,
                    type: type
                )
            }
            item.modify(tags: tags)
        }
    }
}

// swiftlint:enable no_magic_numbers

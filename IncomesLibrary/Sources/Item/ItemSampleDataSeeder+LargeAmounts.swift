import Foundation
import SwiftData

// The fixture intentionally encodes signed monthly amounts around one million.
// swiftlint:disable no_magic_numbers

extension ItemSampleDataSeeder {
    /// Seeds one item per month whose amounts swing the balance across
    /// roughly ±1,000,000, independent of the current locale's currency.
    static func seedLargeAmountData(
        context: ModelContext,
        baseDate: Date = .now
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
}

// swiftlint:enable no_magic_numbers

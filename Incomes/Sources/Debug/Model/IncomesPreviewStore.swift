//
//  IncomesPreviewStore.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/26.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

@Observable
final class IncomesPreviewStore {
    private(set) var items = [Item]()
    private(set) var tags = [Tag]()

    private var isReady: Bool {
        items.isNotEmpty && tags.isNotEmpty
    }

    @MainActor
    func prepare(_ context: ModelContext) async {
        createItems(context)
        while !isReady {
            try! await Task.sleep(for: .seconds(0.2))
            items = try! context.fetch(.items(.all))
            tags = try! context.fetch(.tags(.all))
        }
        try! BalanceCalculator(context: context).calculate(for: items)
    }

    @MainActor
    func prepareIgnoringDuplicates(_ context: ModelContext) {
        for index in 0..<24 {
            _ = try! Item.createIgnoringDuplicates(
                context: context,
                date: Calendar.utc.date(
                    byAdding: .month,
                    value: index,
                    to: .now
                )!,
                content: "Pension",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 36),
                category: "Tax",
                repeatID: .init()
            )
        }
        try! BalanceCalculator(context: context).calculate(for: items)
    }

    private func createItems(_ context: ModelContext) {
        let now = Calendar.utc.startOfYear(for: .now)

        let dateA = Calendar.utc.date(byAdding: .day, value: 0, to: now)!
        let dateB = Calendar.utc.date(byAdding: .day, value: 6, to: now)!
        let dateC = Calendar.utc.date(byAdding: .day, value: 12, to: now)!
        let dateD = Calendar.utc.date(byAdding: .day, value: 18, to: now)!
        let dateE = Calendar.utc.date(byAdding: .day, value: 24, to: now)!

        let date = { (value: Int, to: Date) -> Date in
            Calendar.utc.date(byAdding: .month, value: value, to: to)!
        }

        for index in 0..<24 {
            _ = try! Item.create(
                context: context,
                date: date(index, dateD),
                content: "Payday",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 3_500),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                category: "Salary",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateD),
                content: "Advertising revenue",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 485),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                category: "Salary",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateB),
                content: "Apple card",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_000),
                category: "Credit",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateA),
                content: "Orange card",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 800),
                category: "Credit",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateD),
                content: "Lemon card",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 500),
                category: "Credit",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateE),
                content: "House",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 30),
                category: "Loan",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateC),
                content: "Car",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 25),
                category: "Loan",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateA),
                content: "Insurance",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 28),
                category: "Tax",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateE),
                content: "Pension",
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 36),
                category: "Tax",
                repeatID: .init()
            )
        }
    }
}

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
    func prepare(_ container: ModelContainer) async {
        createItems(container)
        while !isReady {
            try! await Task.sleep(for: .seconds(0.2))
            items = try! container.mainContext.fetch(.items(.all))
            tags = try! container.mainContext.fetch(.tags(.all))
        }
        try! BalanceCalculator().calculate(in: container.mainContext, for: items)
    }

    @MainActor
    func prepareIgnoringDuplicates(_ container: ModelContainer) {
        for index in 0..<24 {
            _ = try! Item.createIgnoringDuplicates(
                container: container,
                date: Calendar.current.date(
                    byAdding: .month,
                    value: index,
                    to: .now
                )!,
                content: String(localized: "Pension"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 36),
                category: String(localized: "Tax"),
                repeatID: .init()
            )
        }
        try! BalanceCalculator().calculate(in: container.mainContext, for: items)
    }

    private func createItems(_ container: ModelContainer) {
        let now = Calendar.current.startOfYear(for: .now)

        let dateA = Calendar.current.date(byAdding: .day, value: 0, to: now)!
        let dateB = Calendar.current.date(byAdding: .day, value: 6, to: now)!
        let dateC = Calendar.current.date(byAdding: .day, value: 12, to: now)!
        let dateD = Calendar.current.date(byAdding: .day, value: 18, to: now)!
        let dateE = Calendar.current.date(byAdding: .day, value: 24, to: now)!

        let date = { (value: Int, to: Date) -> Date in
            Calendar.current.date(byAdding: .month, value: value, to: to)!
        }

        _ = try! Item.create(
            container: container,
            date: date(-1, dateD),
            content: String(localized: "Payday"),
            income: LocaleAmountConverter.localizedAmount(baseUSD: 4_500),
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
            category: String(localized: "Salary"),
            repeatID: .init()
        )

        for index in 0..<24 {
            _ = try! Item.create(
                container: container,
                date: date(index, dateD),
                content: String(localized: "Payday"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 4_500),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                category: String(localized: "Salary"),
                repeatID: .init()
            )
            _ = try! Item.create(
                container: container,
                date: date(index, dateD),
                content: String(localized: "Advertising revenue"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 500),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                category: String(localized: "Salary"),
                repeatID: .init()
            )
            _ = try! Item.create(
                container: container,
                date: date(index, dateB),
                content: String(localized: "Apple card"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 900),
                category: String(localized: "Credit"),
                repeatID: .init()
            )
            _ = try! Item.create(
                container: container,
                date: date(index, dateA),
                content: String(localized: "Orange card"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 600),
                category: String(localized: "Credit"),
                repeatID: .init()
            )
            _ = try! Item.create(
                container: container,
                date: date(index, dateD),
                content: String(localized: "Lemon card"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 500),
                category: String(localized: "Credit"),
                repeatID: .init()
            )
            _ = try! Item.create(
                container: container,
                date: date(index, dateE),
                content: String(localized: "House"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_800),
                category: String(localized: "Loan"),
                repeatID: .init()
            )
            _ = try! Item.create(
                container: container,
                date: date(index, dateC),
                content: String(localized: "Car"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 300),
                category: String(localized: "Loan"),
                repeatID: .init()
            )
            _ = try! Item.create(
                container: container,
                date: date(index, dateA),
                content: String(localized: "Insurance"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 250),
                category: String(localized: "Tax"),
                repeatID: .init()
            )
            _ = try! Item.create(
                container: container,
                date: date(index, dateE),
                content: String(localized: "Pension"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 300),
                category: String(localized: "Tax"),
                repeatID: .init()
            )
        }
    }
}

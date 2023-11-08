//
//  PreviewData.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/26.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

// swiftlint:disable force_unwrapping force_try no_magic_numbers function_body_length
enum PreviewData {
    static var store = Store()

    static var context: ModelContext {
        let context = try! ModelContext(
            .init(for: Item.self,
                  configurations: .init(isStoredInMemoryOnly: true))
        )
        _ = try! items(context: context)
        return context
    }

    static var items: [Item] {
        try! ItemService(context: context).items()
    }

    static var tags: [Tag] {
        try! TagService(context: context).tags()
    }

    static func items(context: ModelContext) throws -> [Item] {
        var items: [Item] = []

        let factory = ItemFactory(context: context)
        let service = ItemService(context: context)

        let now = Calendar.utc.startOfYear(for: Date())
        let dateA = Calendar.utc.date(byAdding: .day, value: 0, to: now)!
        let dateB = Calendar.utc.date(byAdding: .day, value: 6, to: now)!
        let dateC = Calendar.utc.date(byAdding: .day, value: 12, to: now)!
        let dateD = Calendar.utc.date(byAdding: .day, value: 18, to: now)!
        let dateE = Calendar.utc.date(byAdding: .day, value: 24, to: now)!

        for index in 0..<24 {
            items.append(try factory(date: date(monthLater: index, from: dateD),
                                     content: "Payday",
                                     income: 3_500,
                                     outgo: 0,
                                     group: "Salary",
                                     repeatID: UUID()))
            items.append(try factory(date: date(monthLater: index, from: dateD),
                                     content: "Advertising revenue",
                                     income: 485,
                                     outgo: 0,
                                     group: "Salary",
                                     repeatID: UUID()))
            items.append(try factory(date: date(monthLater: index, from: dateB),
                                     content: "Apple card",
                                     income: 0,
                                     outgo: 1_000,
                                     group: "Credit",
                                     repeatID: UUID()))
            items.append(try factory(date: date(monthLater: index, from: dateA),
                                     content: "Orange card",
                                     income: 0,
                                     outgo: 800,
                                     group: "Credit",
                                     repeatID: UUID()))
            items.append(try factory(date: date(monthLater: index, from: dateD),
                                     content: "Lemon card",
                                     income: 0,
                                     outgo: 500,
                                     group: "Credit",
                                     repeatID: UUID()))
            items.append(try factory(date: date(monthLater: index, from: dateE),
                                     content: "House",
                                     income: 0,
                                     outgo: 30,
                                     group: "Loan",
                                     repeatID: UUID()))
            items.append(try factory(date: date(monthLater: index, from: dateC),
                                     content: "Car",
                                     income: 0,
                                     outgo: 25,
                                     group: "Loan",
                                     repeatID: UUID()))
            items.append(try factory(date: date(monthLater: index, from: dateA),
                                     content: "Insurance",
                                     income: 0,
                                     outgo: 28,
                                     group: "Tax",
                                     repeatID: UUID()))
            items.append(try factory(date: date(monthLater: index, from: dateE),
                                     content: "Pension",
                                     income: 0,
                                     outgo: 36,
                                     group: "Tax",
                                     repeatID: UUID()))
        }

        try service.calculate(for: items)

        return items
    }

    private static func date(monthLater: Int, from date: Date = Date()) -> Date {
        Calendar.utc.date(byAdding: .month, value: monthLater, to: date)!
    }
}
// swiftlint:enable force_unwrapping force_try no_magic_numbers function_body_length

// MARK: - Preview modifier

// periphery:ignore
extension View {
    func previewNavigation() -> some View {
        NavigationStack {
            self
        }
    }

    func previewList() -> some View {
        List {
            self
        }
    }

    func previewQuery() -> some View {
        modelContext(PreviewData.context)
    }

    func previewStore() -> some View {
        environment(PreviewData.store)
    }

    func previewJapanese() -> some View {
        environment(\.locale, .init(identifier: "ja"))
    }

    func previewIsSubscribeOn(_ value: Bool) -> some View {
        onAppear {
            UserDefaults.isSubscribeOn = value
        }
    }
}

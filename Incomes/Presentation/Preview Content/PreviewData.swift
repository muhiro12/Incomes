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
    @StateObject static var store = Store()

    static var inMemoryContainer: ModelContainer {
        let schema = Schema([Item.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        Task { @MainActor in
            let sampleData = try! items(context: container.mainContext)
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        }
        return container
    }

    static func items(context: ModelContext) throws -> [Item] {
        var items: [Item] = []

        let factory = ItemFactory(context: context)

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

        return items
    }

    private static func date(monthLater: Int, from date: Date = Date()) -> Date {
        Calendar.utc.date(byAdding: .month, value: monthLater, to: date)!
    }
}
// swiftlint:enable force_unwrapping force_try no_magic_numbers function_body_length

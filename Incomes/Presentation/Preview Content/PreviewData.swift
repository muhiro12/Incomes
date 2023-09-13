//
//  PreviewData.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/26.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

// swiftlint:disable force_unwrapping force_try no_magic_numbers
enum PreviewData {
    @StateObject static var store = Store()

    static var inMemoryContainer: ModelContainer {
        let schema = Schema([Item.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let sampleData: [any PersistentModel] = items
        Task { @MainActor in
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        }
        return container
    }

    static var items: [Item] {
        var items: [Item] = []

        let now = Calendar.utc.startOfYear(for: Date())
        let dateA = Calendar.utc.date(byAdding: .day, value: 0, to: now)!
        let dateB = Calendar.utc.date(byAdding: .day, value: 6, to: now)!
        let dateC = Calendar.utc.date(byAdding: .day, value: 12, to: now)!
        let dateD = Calendar.utc.date(byAdding: .day, value: 18, to: now)!
        let dateE = Calendar.utc.date(byAdding: .day, value: 24, to: now)!

        for index in 0..<24 {
            items.append(item(date: date(monthLater: index, from: dateD),
                              content: "Payday",
                              income: 3_500,
                              outgo: 0,
                              group: "Salary",
                              repeatID: UUID()))
            items.append(item(date: date(monthLater: index, from: dateD),
                              content: "Advertising revenue",
                              income: 485,
                              outgo: 0,
                              group: "Salary",
                              repeatID: UUID()))
            items.append(item(date: date(monthLater: index, from: dateB),
                              content: "Apple card",
                              income: 0,
                              outgo: 1_000,
                              group: "Credit",
                              repeatID: UUID()))
            items.append(item(date: date(monthLater: index, from: dateA),
                              content: "Orange card",
                              income: 0,
                              outgo: 800,
                              group: "Credit",
                              repeatID: UUID()))
            items.append(item(date: date(monthLater: index, from: dateD),
                              content: "Lemon card",
                              income: 0,
                              outgo: 500,
                              group: "Credit",
                              repeatID: UUID()))
            items.append(item(date: date(monthLater: index, from: dateE),
                              content: "House",
                              income: 0,
                              outgo: 30,
                              group: "Loan",
                              repeatID: UUID()))
            items.append(item(date: date(monthLater: index, from: dateC),
                              content: "Car",
                              income: 0,
                              outgo: 25,
                              group: "Loan",
                              repeatID: UUID()))
            items.append(item(date: date(monthLater: index, from: dateA),
                              content: "Insurance",
                              income: 0,
                              outgo: 28,
                              group: "Tax",
                              repeatID: UUID()))
            items.append(item(date: date(monthLater: index, from: dateE),
                              content: "Pension",
                              income: 0,
                              outgo: 36,
                              group: "Tax",
                              repeatID: UUID()))
        }

        return items
    }

    static var item: Item {
        items.first!
    }

    private static func item(date: Date, // swiftlint:disable:this function_parameter_count
                             content: String,
                             income: Decimal,
                             outgo: Decimal,
                             group: String,
                             repeatID: UUID) -> Item {
        let item = Item()
        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: repeatID)
        item.set(tags: [
            tag(Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy), for: .year),
            tag(Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM), for: .yearMonth),
            tag(content, for: .content),
            tag(group, for: .category)
        ])
        return item
    }

    private static func tag(_ name: String, for type: Tag.TagType) -> Tag {
        let tag = Tag()
        tag.set(name: name, typeID: type.rawValue)
        return tag
    }

    private static func date(monthLater: Int, from date: Date = Date()) -> Date {
        Calendar.utc.date(byAdding: .month, value: monthLater, to: date)!
    }
}
// swiftlint:enable force_unwrapping force_try no_magic_numbers

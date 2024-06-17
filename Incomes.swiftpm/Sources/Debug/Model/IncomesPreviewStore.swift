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
        !items.isEmpty
            && tags.isEmpty
    }

    @MainActor
    func prepare(_ context: ModelContext) async {
        createItems(context)
        while !isReady {
            try! await Task.sleep(for: .seconds(0.2))
            items = try! context.fetch(.init())
            tags = try! context.fetch(.init())
        }
    }

    private func createItems(_ context: ModelContext) {
        let now = Calendar.utc.startOfYear(for: Date())

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
                income: 3_500,
                outgo: 0,
                group: "Salary",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateD),
                content: "Advertising revenue",
                income: 485,
                outgo: 0,
                group: "Salary",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateB),
                content: "Apple card",
                income: 0,
                outgo: 1_000,
                group: "Credit",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateA),
                content: "Orange card",
                income: 0,
                outgo: 800,
                group: "Credit",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateD),
                content: "Lemon card",
                income: 0,
                outgo: 500,
                group: "Credit",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateE),
                content: "House",
                income: 0,
                outgo: 30,
                group: "Loan",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateC),
                content: "Car",
                income: 0,
                outgo: 25,
                group: "Loan",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateA),
                content: "Insurance",
                income: 0,
                outgo: 28,
                group: "Tax",
                repeatID: .init()
            )
            _ = try! Item.create(
                context: context,
                date: date(index, dateE),
                content: "Pension",
                income: 0,
                outgo: 36,
                group: "Tax",
                repeatID: .init()
            )
        }
    }
}

@available(*, deprecated)
extension IncomesPreviewStore {
    static var context: ModelContext {
        try! ModelContext(
            .init(for: Item.self,
                  configurations: .init(isStoredInMemoryOnly: true))
        )
    }

    static var items: [Item] {
        try! context.fetch(.init(sortBy: Item.sortDescriptors()))
    }

    static var tags: [Tag] {
        try! context.fetch(.init( sortBy: Tag.sortDescriptors()))
    }
}

// MARK: - Preview modifier

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

    func previewContext() -> some View {
        modelContext(IncomesPreviewStore.context)
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

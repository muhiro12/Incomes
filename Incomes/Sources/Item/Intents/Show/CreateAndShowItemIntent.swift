//
//  CreateAndShowItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct CreateAndShowItemIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, date: Date, content: String, income: Double, outgo: Double, category: String, repeatCount: Int)
    typealias Output = ItemEntity

    @Parameter(title: "Date", kind: .date)
    private var date: Date
    @Parameter(title: "Content")
    private var content: String
    @Parameter(title: "Income")
    private var income: Double
    @Parameter(title: "Outgo")
    private var outgo: Double
    @Parameter(title: "Category")
    private var category: String
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60))
    private var repeatCount: Int

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Create and Show Item", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let (container, date, content, income, outgo, category, repeatCount) = input
        guard content.isNotEmpty else {
            throw ItemError.contentIsEmpty
        }
        return try CreateItemIntent.perform(
            (
                container: container,
                date: date,
                content: content,
                income: .init(income),
                outgo: .init(outgo),
                category: category,
                repeatCount: repeatCount
            )
        )
    }

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let item = try Self.perform((container: modelContainer,
                                     date: date,
                                     content: content,
                                     income: income,
                                     outgo: outgo,
                                     category: category,
                                     repeatCount: repeatCount))
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}

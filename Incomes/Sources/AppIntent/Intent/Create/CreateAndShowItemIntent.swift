//
//  CreateAndShowItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct CreateAndShowItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Create and Show Item", table: "AppIntents")

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

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, content: String, income: Double, outgo: Double, category: String, repeatCount: Int, itemService: ItemService)
    typealias Output = ItemEntity

    static func perform(_ input: Input) throws -> Output {
        let (date, content, income, outgo, category, repeatCount, itemService) = input
        guard content.isNotEmpty else {
            throw DebugError.default
        }
        let item = try itemService.create(
            date: date,
            content: content,
            income: .init(income),
            outgo: .init(outgo),
            category: category,
            repeatCount: repeatCount
        )
        guard let entity = ItemEntity(item) else {
            throw DebugError.default
        }
        return entity
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let item = try Self.perform((date: date,
                                     content: content,
                                     income: income,
                                     outgo: outgo,
                                     category: category,
                                     repeatCount: repeatCount,
                                     itemService: itemService))
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}

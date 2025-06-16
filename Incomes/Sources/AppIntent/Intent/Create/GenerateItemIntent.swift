//
//  GenerateItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/16.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import FoundationModels
import SwiftUtilities

@Generable
struct GeneratedItem {
    @Guide(description: "Date in yyyy-MM-dd format")
    var date: String
    @Guide(description: "Content text")
    var content: String
    @Guide(description: "Income amount")
    var income: Double
    @Guide(description: "Outgo amount")
    var outgo: Double
    @Guide(description: "Category name")
    var category: String
}

struct GenerateItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Generate Item", table: "AppIntents")

    @Parameter(title: "Text")
    private var text: String

    @Dependency private var itemService: ItemService

    typealias Input = (text: String, itemService: ItemService)
    typealias Output = ItemEntity

    static func perform(_ input: Input) async throws -> Output {
        let (text, itemService) = input
        let session = LanguageModelSession()
        let prompt = """
            Extract item details from the following text.
            Respond with a JSON containing date(yyyy-MM-dd), content, income, outgo and category.
            \(text)
            """
        let generated = try await session.respond(
            to: prompt,
            generating: GeneratedItem.self
        ).content

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: generated.date) else {
            throw DebugError.default
        }

        let model = try itemService.create(
            date: date,
            content: generated.content,
            income: .init(generated.income),
            outgo: .init(generated.outgo),
            category: generated.category
        )
        guard let entity = ItemEntity(model) else {
            throw DebugError.default
        }
        return entity
    }

    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        let item = try await Self.perform((text: text, itemService: itemService))
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}

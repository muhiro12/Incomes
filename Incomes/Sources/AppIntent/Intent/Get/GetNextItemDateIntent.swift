//
//  GetNextItemDateIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUtilities

struct GetNextItemDateIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Next Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, date: Date)
    typealias Output = Date?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetNextItemIntent.perform((context: input.context, date: input.date)) else {
            return nil
        }
        return item.date
    }

    func perform() throws -> some ReturnsValue<Date?> {
        guard let item = try GetNextItemIntent.perform((context: modelContainer.mainContext, date: date)) else {
            return .result(value: nil)
        }
        return .result(value: item.date)
    }
}

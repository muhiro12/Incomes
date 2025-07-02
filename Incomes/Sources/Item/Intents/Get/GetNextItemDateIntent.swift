//
//  GetNextItemDateIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct GetNextItemDateIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, date: Date)
    typealias Output = Date?

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Next Item Date", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetNextItemIntent.perform((container: input.container, date: input.date)) else {
            return nil
        }
        return item.date
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        guard let item = try GetNextItemIntent.perform((container: modelContainer, date: date)) else {
            return .result(value: nil)
        }
        return .result(value: item.date)
    }
}

//
//  GetNextItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct GetNextItemIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, date: Date)
    typealias Output = ItemEntity?

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Next Item", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let descriptor = FetchDescriptor.items(.dateIsAfter(input.date), order: .forward)
        guard let item = try input.container.mainContext.fetchFirst(descriptor) else {
            return nil
        }
        return .init(item)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try Self.perform((container: modelContainer, date: date)) else {
            return .result(value: nil)
        }
        return .result(value: item)
    }
}

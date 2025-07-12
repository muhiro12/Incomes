//
//  OpenIncomesIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct OpenIncomesIntent: AppIntent, IntentPerformer {
    typealias Input = Void
    typealias Output = Void

    nonisolated static let title: LocalizedStringResource = .init("Open Incomes", table: "AppIntents")
    nonisolated static let openAppWhenRun = true

    static func perform(_: Input) throws -> Output {}

    func perform() throws -> some IntentResult {
        try Self.perform(())
        return .result()
    }
}

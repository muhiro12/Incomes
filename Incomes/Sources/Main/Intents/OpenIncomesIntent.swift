//
//  OpenIncomesIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

@MainActor
struct OpenIncomesIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = .init("Open Incomes", table: "AppIntents")
    nonisolated static let openAppWhenRun = true

    func perform() throws -> some IntentResult {
        MainService.open()
        return .result()
    }
}

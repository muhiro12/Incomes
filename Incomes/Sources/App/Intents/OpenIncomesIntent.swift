//
//  OpenIncomesIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//

import AppIntents

struct OpenIncomesIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Open Incomes", table: "AppIntents")
    static let openAppWhenRun = true

    @MainActor
    func perform() -> some IntentResult {
        .result()
    }
}

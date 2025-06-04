//
//  OpenIncomesIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct OpenIncomesIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Open Incomes", table: "AppIntents")
    static let openAppWhenRun = true

    static func perform() -> some IntentResult {
        .result()
    }

    func perform() throws -> some IntentResult {
        Self.perform()
    }
}

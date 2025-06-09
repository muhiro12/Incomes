//
//  OpenIncomesIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct OpenIncomesIntent: StaticPerformIntent {
    static let title: LocalizedStringResource = .init("Open Incomes", table: "AppIntents")
    static let openAppWhenRun = true

    typealias Arguments = Void

    static func perform(_ arguments: Arguments = ()) throws -> any IntentResult {
        .result()
    }

    func perform() throws -> some IntentResult {
        try Self.perform()
    }
}

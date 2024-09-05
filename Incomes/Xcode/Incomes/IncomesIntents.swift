//
//  IncomesIntents.swift
//  Incomes
//
//  Created by Hiromu Nakano on 9/5/24.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct OpenIncomesIntent: AppIntent {
    static var title = LocalizedStringResource("Open Incomes")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

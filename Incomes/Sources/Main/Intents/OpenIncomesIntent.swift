//
//  OpenIncomesIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUtilities

struct OpenIncomesIntent: AppIntent, IntentPerformer {
    typealias Input = Void
    typealias Output = Void

    static let title: LocalizedStringResource = .init("Open Incomes", table: "AppIntents")
    static let openAppWhenRun = true

    @MainActor
    static func perform(_: Input) throws -> Output {}

    func perform() throws -> some IntentResult {
        try Self.perform(())
        return .result()
    }
}

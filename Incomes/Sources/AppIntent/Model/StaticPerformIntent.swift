//
//  StaticPerformIntent.swift
//  Incomes
//
//  Created by Codex on 2025/06/09.
//

import AppIntents

protocol StaticPerformIntent: AppIntent {
    associatedtype Arguments

    static func perform(_ arguments: Arguments) throws -> any IntentResult
}

//
//  IntroductionTutorialSeeder.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import SwiftData

enum IntroductionTutorialSeeder {
    // Temporary kill-switch for tutorial seeding during release stabilization.
    private static let isSeedingEnabled = false

    static func seed(context: ModelContext) throws {
        guard isSeedingEnabled else {
            return
        }
        try ItemService.seedTutorialDataIfNeeded(context: context)
    }
}

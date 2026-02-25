//
//  IntroductionTutorialSeeder.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import SwiftData

enum IntroductionTutorialSeeder {
    static func seed(context: ModelContext) throws {
        try ItemService.seedTutorialDataIfNeeded(context: context)
    }
}

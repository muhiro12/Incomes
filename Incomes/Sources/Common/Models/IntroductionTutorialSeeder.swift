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

enum IntroductionPresentationPolicy {
    // Temporary kill-switch for tutorial presentation while iCloud startup behavior is under investigation.
    static let isEnabled = false
}

//
//  IncomesShortcuts.swift
//  Incomes
//
//  Created by Hiromu Nakano on 9/8/24.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import AppIntents

// MARK: - Shortcut

struct IncomesShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] = [
        AppShortcut(
            intent: ShowItemListIntent(),
            phrases: [
                "Show item list in \(.applicationName)"
            ],
            shortTitle: "Show Item List",
            systemImageName: "list.dash.header.rectangle"
        ),
        AppShortcut(
            intent: ShowNextItemIntent(),
            phrases: [
                "Show next item in \(.applicationName)"
            ],
            shortTitle: "Show Next Item",
            systemImageName: "list.dash.header.rectangle"
        ),
        AppShortcut(
            intent: ShowPreviousItemIntent(),
            phrases: [
                "Show previous item in \(.applicationName)"
            ],
            shortTitle: "Show Previous Item",
            systemImageName: "list.dash.header.rectangle"
        )
    ]
}

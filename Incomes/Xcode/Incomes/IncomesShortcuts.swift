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
    static let shortcutTileColor = ShortcutTileColor.lime

    static let appShortcuts = [
        AppShortcut(
            intent: OpenIncomesIntent(),
            phrases: [
                "Open \(.applicationName)"
            ],
            shortTitle: "Open Incomes",
            systemImageName: "dollarsign.circle"
        ),
        AppShortcut(
            intent: ShowItemsIntent(),
            phrases: [
                "Show items in \(.applicationName)"
            ],
            shortTitle: "Show Items",
            systemImageName: "list.bullet.rectangle"
        ),
        AppShortcut(
            intent: ShowChartsIntent(),
            phrases: [
                "Show charts in \(.applicationName)"
            ],
            shortTitle: "Show Charts",
            systemImageName: "chart.pie"
        ),
        AppShortcut(
            intent: ShowNextItemsIntent(),
            phrases: [
                "Show next items in \(.applicationName)"
            ],
            shortTitle: "Show Next Items",
            systemImageName: "list.dash.header.rectangle"
        ),
        AppShortcut(
            intent: ShowPreviousItemsIntent(),
            phrases: [
                "Show previous items in \(.applicationName)"
            ],
            shortTitle: "Show Previous Items",
            systemImageName: "list.dash.header.rectangle"
        )
    ]
}

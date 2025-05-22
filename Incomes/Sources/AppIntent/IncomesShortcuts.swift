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
                "Open \(.applicationName)",
                "Launch \(.applicationName)",
                "Start \(.applicationName)",
                "Access \(.applicationName)"
            ],
            shortTitle: "Open Incomes",
            systemImageName: "dollarsign.circle"
        ),
        AppShortcut(
            intent: ShowItemsIntent(),
            phrases: [
                "Show items in \(.applicationName)",
                "View my items using \(.applicationName)",
                "Check my items in \(.applicationName)",
                "List my entries in \(.applicationName)"
            ],
            shortTitle: "Show Items",
            systemImageName: "list.bullet.rectangle"
        ),
        AppShortcut(
            intent: ShowChartsIntent(),
            phrases: [
                "Show charts in \(.applicationName)",
                "View charts with \(.applicationName)",
                "Display stats from \(.applicationName)",
                "Check analytics in \(.applicationName)"
            ],
            shortTitle: "Show Charts",
            systemImageName: "chart.pie"
        ),
        AppShortcut(
            intent: ShowNextItemsIntent(),
            phrases: [
                "Show next items in \(.applicationName)",
                "What’s upcoming in \(.applicationName)",
                "Check next payments in \(.applicationName)",
                "Upcoming entries in \(.applicationName)"
            ],
            shortTitle: "Show Next Items",
            systemImageName: "list.dash.header.rectangle"
        ),
        AppShortcut(
            intent: GetNextItem(),
            phrases: [
                "Get next item in \(.applicationName)",
                "What is next in \(.applicationName)",
                "Next entry in \(.applicationName)",
                "Continue to next in \(.applicationName)"
            ],
            shortTitle: "Get Next Item",
            systemImageName: "arrow.down.circle"
        ),
        AppShortcut(
            intent: ShowPreviousItemsIntent(),
            phrases: [
                "Show previous items in \(.applicationName)",
                "View history in \(.applicationName)",
                "List past entries in \(.applicationName)",
                "Past transactions with \(.applicationName)"
            ],
            shortTitle: "Show Previous Items",
            systemImageName: "list.dash.header.rectangle"
        ),
        AppShortcut(
            intent: GetPreviousItem(),
            phrases: [
                "Get previous item in \(.applicationName)",
                "What was before in \(.applicationName)",
                "Previous entry in \(.applicationName)",
                "Return to previous in \(.applicationName)"
            ],
            shortTitle: "Get Previous Item",
            systemImageName: "arrow.up.circle"
        )
    ]
}

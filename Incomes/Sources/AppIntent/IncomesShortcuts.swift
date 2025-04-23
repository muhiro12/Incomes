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
                .init(.init(localized: "Open ${applicationName}")),
                .init(.init(localized: "Launch ${applicationName}")),
                .init(.init(localized: "Start ${applicationName}")),
                .init(.init(localized: "Access ${applicationName}"))
            ],
            shortTitle: "Open Incomes",
            systemImageName: "dollarsign.circle"
        ),
        AppShortcut(
            intent: ShowItemsIntent(),
            phrases: [
                .init(.init(localized: "Show items in ${applicationName}")),
                .init(.init(localized: "View my items using ${applicationName}")),
                .init(.init(localized: "Check my items in ${applicationName}")),
                .init(.init(localized: "List my entries in ${applicationName}"))
            ],
            shortTitle: "Show Items",
            systemImageName: "list.bullet.rectangle"
        ),
        AppShortcut(
            intent: ShowChartsIntent(),
            phrases: [
                .init(.init(localized: "Show charts in ${applicationName}")),
                .init(.init(localized: "View charts with ${applicationName}")),
                .init(.init(localized: "Display stats from ${applicationName}")),
                .init(.init(localized: "Check analytics in ${applicationName}"))
            ],
            shortTitle: "Show Charts",
            systemImageName: "chart.pie"
        ),
        AppShortcut(
            intent: ShowNextItemsIntent(),
            phrases: [
                .init(.init(localized: "Show next items in ${applicationName}")),
                .init(.init(localized: "What’s upcoming in ${applicationName}")),
                .init(.init(localized: "Check next payments in ${applicationName}")),
                .init(.init(localized: "Upcoming entries in ${applicationName}"))
            ],
            shortTitle: "Show Next Items",
            systemImageName: "list.dash.header.rectangle"
        ),
        AppShortcut(
            intent: ShowPreviousItemsIntent(),
            phrases: [
                .init(.init(localized: "Show previous items in ${applicationName}")),
                .init(.init(localized: "View history in ${applicationName}")),
                .init(.init(localized: "List past entries in ${applicationName}")),
                .init(.init(localized: "Past transactions with ${applicationName}"))
            ],
            shortTitle: "Show Previous Items",
            systemImageName: "list.dash.header.rectangle"
        )
    ]
}

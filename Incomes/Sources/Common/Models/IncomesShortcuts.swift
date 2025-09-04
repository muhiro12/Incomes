//
//  IncomesShortcuts.swift
//  Incomes
//
//  Created by Hiromu Nakano on 9/8/24.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct IncomesShortcuts: AppShortcutsProvider {
    static let shortcutTileColor = ShortcutTileColor.lime

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenIncomesIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Launch \(.applicationName)",
                "Start \(.applicationName)",
                "Access \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Open Incomes", table: "AppIntents"),
            systemImageName: "dollarsign.circle"
        )
        AppShortcut(
            intent: CreateAndShowItemIntent(),
            phrases: [
                "Create and view item in \(.applicationName)",
                "Add and show entry in \(.applicationName)",
                "Log and display transaction in \(.applicationName)",
                "Create then reveal item in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Create and Show Item", table: "AppIntents"),
            systemImageName: "plus.circle"
        )
        AppShortcut(
            intent: ShowThisMonthItemsIntent(),
            phrases: [
                "Show items in \(.applicationName)",
                "Let me see my items with \(.applicationName)",
                "Show this month’s items in \(.applicationName)",
                "List current month’s items in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("This Month’s Items", table: "AppIntents"),
            systemImageName: "list.bullet.rectangle"
        )
        AppShortcut(
            intent: ShowThisMonthChartsIntent(),
            phrases: [
                "Check charts in \(.applicationName)",
                "Let me see the stats in \(.applicationName)",
                "Show this month’s charts in \(.applicationName)",
                "Display charts for the current month in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("This Month’s Charts", table: "AppIntents"),
            systemImageName: "chart.pie"
        )
        AppShortcut(
            intent: ShowUpcomingItemIntent(),
            phrases: [
                "What’s next in \(.applicationName)",
                "Show me the next thing in \(.applicationName)",
                "Show upcoming item in \(.applicationName)",
                "Reveal the upcoming entry in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Upcoming Item", table: "AppIntents"),
            systemImageName: "arrow.down.circle"
        )
        AppShortcut(
            intent: ShowUpcomingItemsIntent(),
            phrases: [
                "What’s coming up in \(.applicationName)",
                "Show me what’s next in \(.applicationName)",
                "Show upcoming items in \(.applicationName)",
                "Check what’s coming in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Upcoming Items", table: "AppIntents"),
            systemImageName: "list.dash.header.rectangle"
        )
        AppShortcut(
            intent: ShowRecentItemIntent(),
            phrases: [
                "What did I do last in \(.applicationName)",
                "Show me the latest item in \(.applicationName)",
                "Show recent item in \(.applicationName)",
                "Reveal most recent item in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Recent Item", table: "AppIntents"),
            systemImageName: "arrow.up.circle"
        )
        AppShortcut(
            intent: ShowRecentItemsIntent(),
            phrases: [
                "What did I record recently in \(.applicationName)",
                "Show me recent records in \(.applicationName)",
                "Show recent items in \(.applicationName)",
                "Most recent items with \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Recent Items", table: "AppIntents"),
            systemImageName: "list.dash.header.rectangle"
        )
    }
}

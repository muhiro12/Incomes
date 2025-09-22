//
//  IncomesWatchApp.swift
//  Watch
//
//  Created by Hiromu Nakano on 2025/09/15.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

@main
struct IncomesWatchApp: App {
    private var sharedModelContainer: ModelContainer!

    init() {
        // Migrate possible legacy DB files into App Group first
        DatabaseMigrator.migrateSQLiteFilesIfNeeded()

        let modelContainer = try! ModelContainer(
            for: Item.self,
            configurations: .init(
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
        )

        sharedModelContainer = modelContainer
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}

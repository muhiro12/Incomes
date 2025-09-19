//
//  IncomesWatchApp.swift
//  Watch
//
//  Created by Hiromu Nakano on 2025/09/15.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import StoreKit
import StoreKitWrapper
import SwiftData
import SwiftUI

@main
struct IncomesWatchApp: App {
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private var sharedModelContainer: ModelContainer!
    private var sharedStore: Store!

    init() {
        // Migrate possible legacy DB files into App Group first
        DatabaseMigrator.migrateSQLiteFilesIfNeeded()

        let modelContainer = try! ModelContainer(
            for: Item.self,
            configurations: .init(
                url: Database.url,
                cloudKitDatabase: isICloudOn ? .automatic : .none
            )
        )

        sharedModelContainer = modelContainer

        sharedStore = .init()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(isICloudOn)
                .modelContainer(sharedModelContainer)
                .environment(sharedStore)
        }
    }
}

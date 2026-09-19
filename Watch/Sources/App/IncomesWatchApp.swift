//
//  IncomesWatchApp.swift
//  Watch
//
//  Created by Hiromu Nakano on 2025/09/15.
//

import AppIntents
import SwiftData
import SwiftUI

@main
struct IncomesWatchApp: App {
    private let sharedModelContainer: ModelContainer

    init() {
        _ = IncomesPreferenceLifecycle.runSynchronously()

        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainerFactory.inMemory()
        } catch {
            preconditionFailure("Failed to initialize watch model container: \(error)")
        }

        sharedModelContainer = modelContainer
    }
}

extension IncomesWatchApp {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}

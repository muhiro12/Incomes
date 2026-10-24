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
        #if DEBUG
        if WatchScreenshotSupport.isEnabled {
            sharedModelContainer = WatchScreenshotSupport.makeModelContainer()
            return
        }
        #endif

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
            #if DEBUG
            if WatchScreenshotSupport.isEnabled {
                appContent
                    .defaultAppStorage(WatchScreenshotSupport.preferences)
            } else {
                appContent
            }
            #else
            appContent
            #endif
        }
    }

    private var appContent: some View {
        ContentView()
            .modelContainer(sharedModelContainer)
    }
}

//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Firebase
import GoogleMobileAds
import SwiftData
import SwiftUI

@main
struct IncomesApp {
    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    private let sharedStore: Store
    private let sharedNotificationService: NotificationService

    private let container = {
        let url = URL.applicationSupportDirectory.appendingPathComponent("Incomes.sqlite")
        let configuration = ModelConfiguration(url: url)
        do {
            return try ModelContainer(for: Item.self, configurations: configuration)
        } catch {
            fatalError("Failed to create the model container: \(error.localizedDescription)")
        }
    }()

    @MainActor
    init() {
        FirebaseApp.configure()

        sharedStore = .init()
        sharedNotificationService = .init()

        if !isSubscribeOn {
            Task {
                await GADMobileAds.sharedInstance().start()
            }
        }

        SwiftDataController(context: container.mainContext).modify()
    }
}

extension IncomesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await sharedNotificationService.register()
                }
        }
        .environment(sharedStore)
        .environment(sharedNotificationService)
        .modelContainer(container)
    }
}

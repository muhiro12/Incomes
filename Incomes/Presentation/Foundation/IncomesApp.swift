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
    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = UserDefaults.isSubscribeOn
    @AppStorage(UserDefaults.Key.isMaskAppOn.rawValue)
    private var isMaskAppOn = UserDefaults.isMaskAppOn
    @AppStorage(UserDefaults.Key.isLockAppOn.rawValue)
    private var isLockAppOn = UserDefaults.isLockAppOn

    @StateObject private var store = Store()

    private let container = {
        let url = URL.applicationSupportDirectory.appendingPathComponent("Incomes.sqlite")
        let configuration = ModelConfiguration(url: url)
        do {
            return try ModelContainer(for: Item.self, configurations: configuration)
        } catch {
            fatalError("Failed to create the model container: \(error.localizedDescription)")
        }
    }()

    init() {
        FirebaseApp.configure()

        if !isSubscribeOn {
            Task {
                await GADMobileAds.sharedInstance().start()
            }
        }
    }
}

extension IncomesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(isMasked: isMaskAppOn, isLocked: isLockAppOn)
        }
        .environmentObject(store)
        .modelContainer(container)
    }
}

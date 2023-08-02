//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import Firebase
import GoogleMobileAds

@main
struct IncomesApp: App {
    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = false

    private let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()
        Store.shared.open()

        if !isSubscribeOn {
            GADMobileAds.sharedInstance().start()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

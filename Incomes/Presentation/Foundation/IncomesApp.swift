//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import Firebase

@main
struct IncomesApp: App {
    init() {
        FirebaseApp.configure()
        Store.shared.configure()
    }

    let persistenceController = PersistenceController.shared

    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .tint(Color.green)
        }
    }
}

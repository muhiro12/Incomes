//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import AppIntents
import GoogleMobileAdsWrapper
import StoreKitWrapper
import SwiftData
import SwiftUI
import TipKit

@main
struct IncomesApp: App {
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.lastLaunchedAppVersion)
    private var lastLaunchedAppVersion

    private var sharedModelContainer: ModelContainer!

    private var sharedNotificationService: NotificationService!
    private var sharedConfigurationService: ConfigurationService!
    private var sharedTipController: IncomesTipController!

    private var sharedStore: Store!
    private var sharedGoogleMobileAdsController: GoogleMobileAdsController!

    @MainActor
    init() {
        DatabaseMigrator.migrateSQLiteFilesIfNeeded()

        let modelContainer = try! ModelContainer(
            for: Item.self,
            configurations: .init(
                url: Database.url,
                cloudKitDatabase: isICloudOn ? .automatic : .none
            )
        )

        let notificationService = NotificationService(modelContainer: modelContainer)
        let configurationService = ConfigurationService()
        let tipController = IncomesTipController()

        sharedModelContainer = modelContainer

        sharedNotificationService = notificationService
        sharedConfigurationService = configurationService
        sharedTipController = tipController

        sharedStore = .init()

        sharedGoogleMobileAdsController = .init(
            adUnitID: {
                #if DEBUG
                Secret.admobNativeIDDev
                #else
                Secret.admobNativeID
                #endif
            }()
        )

        AppDependencyManager.shared.add {
            modelContainer
        }
        AppDependencyManager.shared.add {
            notificationService
        }
        AppDependencyManager.shared.add {
            configurationService
        }

        do {
            try tipController.configureIfNeeded()
        } catch {
            #if DEBUG
            assertionFailure(error.localizedDescription)
            #endif
        }

        if let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            lastLaunchedAppVersion = currentAppVersion
        }

        IncomesShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(isICloudOn)
                .modelContainer(sharedModelContainer)
                .environment(sharedNotificationService)
                .environment(sharedConfigurationService)
                .environment(sharedTipController)
                .environment(sharedStore)
                .environment(sharedGoogleMobileAdsController)
        }
    }
}

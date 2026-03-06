//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//

import AppIntents
import GoogleMobileAdsWrapper
import MHPlatform
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

    private let sharedModelContainer: ModelContainer

    private let sharedNotificationService: NotificationService
    private let sharedConfigurationService: ConfigurationService
    private let sharedTipController: IncomesTipController

    private let sharedStore: Store
    private let sharedGoogleMobileAdsController: GoogleMobileAdsController
    private let startupLogger = Self.makeStartupLogger()

    @MainActor
    init() { // swiftlint:disable:this function_body_length type_contents_order
        startupLogger.notice("app startup began")
        DatabaseMigrator.migrateSQLiteFilesIfNeeded()
        let isICloudEnabled = UserDefaults.standard.bool(
            forKey: BoolAppStorageKey.isICloudOn.rawValue
        )

        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(
                for: Item.self,
                configurations: .init(
                    url: Database.url,
                    cloudKitDatabase: isICloudEnabled ? .automatic : .none
                )
            )
        } catch {
            preconditionFailure("Failed to initialize model container: \(error)")
        }

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
        startupLogger.notice("startup dependencies ready")

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
        startupLogger.notice("startup wiring finished")
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

private extension IncomesApp {
    static func makeStartupLogger() -> MHLogger {
        let policy = MHLogPolicy.default
        let store = MHLogStore(
            policy: policy,
            sinks: [MHOSLogSink()]
        )

        return MHLogger(
            #fileID,
            store: store,
            category: "AppStartup",
            policy: policy
        )
    }
}

//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//

import AppIntents
import MHPlatform
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
    private let sharedAppRuntime: MHAppRuntime
    private let startupLogger = Self.logger(category: "AppStartup")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(isICloudOn)
                .modelContainer(sharedModelContainer)
                .environment(sharedNotificationService)
                .environment(sharedConfigurationService)
                .environment(sharedTipController)
                .environment(sharedAppRuntime)
        }
    }

    @MainActor
    init() {
        startupLogger.notice("app startup began")
        DatabaseMigrator.migrateSQLiteFilesIfNeeded()
        let isICloudEnabled = MHPreferenceStore().bool(
            for: BoolAppStorageKey.isICloudOn.preferenceKey
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
        sharedAppRuntime = Self.makeAppRuntime()
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
}

private extension IncomesApp {
    static var nativeAdUnitID: String {
        #if DEBUG
        Secret.admobNativeIDDev
        #else
        Secret.admobNativeID
        #endif
    }

    @MainActor
    static func makeAppRuntime() -> MHAppRuntime {
        .init(
            configuration: .init(
                subscriptionProductIDs: [Secret.productID],
                nativeAdUnitID: nativeAdUnitID,
                preferencesSuiteName: AppGroup.id,
                showsLicenses: true
            )
        )
    }
}

extension IncomesApp {
    nonisolated static let loggerFactory = MHLoggerFactory.osLogDefault

    nonisolated static func logger(
        category: String,
        source: String = #fileID
    ) -> MHLogger {
        loggerFactory.logger(
            category: category,
            source: source
        )
    }
}

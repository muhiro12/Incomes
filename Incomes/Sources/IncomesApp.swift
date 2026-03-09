//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//

import AppIntents
import MHLogging
import MHPreferences
import SwiftData
import SwiftUI
import TipKit

@main
struct IncomesApp: App {
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.lastLaunchedAppVersion)
    private var lastLaunchedAppVersion

    private let platformEnvironment: IncomesPlatformEnvironment
    private let startupLogger = Self.logger(category: "AppStartup")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(isICloudOn)
                .incomesPlatformEnvironment(platformEnvironment)
        }
    }

    @MainActor
    init() {
        startupLogger.notice("app startup began")
        DatabaseMigrator.migrateSQLiteFilesIfNeeded()
        let isICloudEnabled = MHPreferenceStore().bool(
            for: BoolAppStorageKey.isICloudOn.preferenceKey
        )

        let platformEnvironment: IncomesPlatformEnvironment
        do {
            let modelContainer = try IncomesPlatformEnvironmentFactory.makeAppModelContainer(
                isICloudEnabled: isICloudEnabled
            )
            platformEnvironment = Self.makePlatformEnvironment(
                modelContainer: modelContainer
            )
        } catch {
            preconditionFailure("Failed to initialize model container: \(error)")
        }

        self.platformEnvironment = platformEnvironment
        startupLogger.notice("startup dependencies ready")

        AppDependencyManager.shared.add {
            platformEnvironment.modelContainer
        }
        AppDependencyManager.shared.add {
            platformEnvironment.notificationService
        }
        AppDependencyManager.shared.add {
            platformEnvironment.remoteConfigurationService
        }

        if let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            lastLaunchedAppVersion = currentAppVersion
        }

        IncomesShortcuts.updateAppShortcutParameters()
        startupLogger.notice("startup wiring finished")
    }
}

private extension IncomesApp {
    @MainActor
    static func makePlatformEnvironment(
        modelContainer: ModelContainer
    ) -> IncomesPlatformEnvironment {
        IncomesPlatformEnvironmentFactory.make(
            modelContainer: modelContainer,
            platformMode: .production
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

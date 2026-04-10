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
    @AppStorage(BoolAppStorageKey.isICloudOn)
    private var isICloudOn
    @AppStorage(StringAppStorageKey.lastLaunchedAppVersion, default: "")
    private var lastLaunchedAppVersion

    private let platformEnvironment: IncomesPlatformEnvironment

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(isICloudOn)
                .incomesPlatformEnvironment(platformEnvironment)
        }
    }

    // swiftlint:disable function_body_length
    @MainActor
    init() {
        let logging = IncomesLogging.makeBootstrap()
        let startupLogger = IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.appStartup,
            source: #fileID
        )

        startupLogger.notice("startup.begin")
        startupLogger.notice("database_migration.begin")
        DatabaseMigrator.migrateSQLiteFilesIfNeeded()
        startupLogger.notice("database_migration.completed")
        let isICloudEnabled = MHPreferenceStore().bool(
            for: BoolAppStorageKey.isICloudOn.preferenceKey
        )
        startupLogger.notice(
            "platform_environment.build_requested",
            metadata: IncomesLogging.metadata(
                ("icloud_enabled", IncomesLogging.bool(isICloudEnabled))
            )
        )

        let platformEnvironment: IncomesPlatformEnvironment
        do {
            let modelContainer = try IncomesPlatformEnvironmentFactory.makeAppModelContainer(
                isICloudEnabled: isICloudEnabled
            )
            startupLogger.notice("model_container.created")
            platformEnvironment = Self.makePlatformEnvironment(
                modelContainer: modelContainer,
                logging: logging
            )
        } catch {
            let startupFailureMetadata = IncomesLogging.metadata(
                ("phase", "model_container"),
                ("icloud_enabled", IncomesLogging.bool(isICloudEnabled))
            )
            let failureMetadata = startupFailureMetadata.merging(
                IncomesLogging.errorMetadata(error)
            ) { current, _ in
                current
            }
            startupLogger.critical(
                "startup.failed",
                metadata: failureMetadata
            )
            preconditionFailure("Failed to initialize model container: \(error)")
        }

        self.platformEnvironment = platformEnvironment
        startupLogger.notice("startup.dependencies_ready")

        AppDependencyManager.shared.add {
            platformEnvironment.logging
        }
        AppDependencyManager.shared.add {
            platformEnvironment.modelContainer
        }
        AppDependencyManager.shared.add {
            platformEnvironment.notificationService
        }
        AppDependencyManager.shared.add {
            platformEnvironment.remoteConfigurationService
        }
        startupLogger.notice("startup.dependencies_registered")

        if let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            lastLaunchedAppVersion = currentAppVersion
            startupLogger.notice(
                "app_version.recorded",
                metadata: IncomesLogging.metadata(
                    ("app_version", currentAppVersion)
                )
            )
        }

        IncomesShortcuts.updateAppShortcutParameters()
        startupLogger.notice("startup.ready")
    }
    // swiftlint:enable function_body_length
}

private extension IncomesApp {
    @MainActor
    static func makePlatformEnvironment(
        modelContainer: ModelContainer,
        logging: MHLoggingBootstrap
    ) -> IncomesPlatformEnvironment {
        IncomesPlatformEnvironmentFactory.make(
            modelContainer: modelContainer,
            platformMode: .production,
            logging: logging
        )
    }
}

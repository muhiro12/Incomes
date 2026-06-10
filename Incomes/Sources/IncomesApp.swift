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
    private let platformEnvironment: IncomesPlatformEnvironment

    var body: some Scene {
        WindowGroup {
            IncomesAppRootView(
                platformEnvironment: platformEnvironment
            )
        }
    }

    @MainActor
    init() {
        _ = IncomesPreferenceLifecycle.runSynchronously()
        IncomesAppGroupUserDefaultsCleanup.removeUnknownKeys()

        let preferenceStore = MHPreferenceStore()
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

        let platformEnvironment = Self.makePlatformEnvironment(
            preferenceStore: preferenceStore,
            logging: logging,
            startupLogger: startupLogger
        )
        self.platformEnvironment = platformEnvironment
        startupLogger.notice("startup.dependencies_ready")

        Self.registerDependencies(
            platformEnvironment,
            startupLogger: startupLogger
        )
        Self.recordCurrentAppVersion(
            preferenceStore: preferenceStore,
            startupLogger: startupLogger
        )
        IncomesShortcuts.updateAppShortcutParameters()
        startupLogger.notice("startup.ready")
    }
}

private extension IncomesApp {
    @MainActor
    static func makePlatformEnvironment(
        preferenceStore: MHPreferenceStore,
        logging: MHLoggingBootstrap,
        startupLogger: MHLogger
    ) -> IncomesPlatformEnvironment {
        let isICloudEnabled = preferenceStore.bool(
            for: \.isICloudOn
        )
        startupLogger.notice(
            "platform_environment.build_requested",
            metadata: IncomesLogging.metadata(
                ("icloud_enabled", IncomesLogging.bool(isICloudEnabled))
            )
        )

        var startupFailurePhase = "model_container"
        do {
            let modelContainer = try IncomesPlatformEnvironmentFactory.makeAppModelContainer(
                isICloudEnabled: isICloudEnabled
            )
            startupLogger.notice("model_container.created")
            #if DEBUG
            startupFailurePhase = "ui_smoke_seed"
            try IncomesUISmokeLaunchSupport.prepareIfNeeded(
                modelContainer: modelContainer,
                logger: startupLogger
            )
            #endif
            startupFailurePhase = "platform_environment"
            return Self.makePlatformEnvironment(
                modelContainer: modelContainer,
                logging: logging
            )
        } catch {
            logStartupFailure(
                error,
                phase: startupFailurePhase,
                isICloudEnabled: isICloudEnabled,
                startupLogger: startupLogger
            )
            preconditionFailure("Failed to initialize model container: \(error)")
        }
    }

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

    @MainActor
    static func registerDependencies(
        _ platformEnvironment: IncomesPlatformEnvironment,
        startupLogger: MHLogger
    ) {
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
    }

    static func recordCurrentAppVersion(
        preferenceStore: MHPreferenceStore,
        startupLogger: MHLogger
    ) {
        guard let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        preferenceStore.set(
            currentAppVersion,
            for: \.lastLaunchedAppVersion
        )
        startupLogger.notice(
            "app_version.recorded",
            metadata: IncomesLogging.metadata(
                ("app_version", currentAppVersion)
            )
        )
    }

    static func logStartupFailure(
        _ error: any Error,
        phase: String,
        isICloudEnabled: Bool,
        startupLogger: MHLogger
    ) {
        let startupFailureMetadata = IncomesLogging.metadata(
            ("phase", phase),
            ("icloud_enabled", IncomesLogging.bool(isICloudEnabled))
        )
        startupLogger.critical(
            "startup.failed",
            metadata: startupFailureMetadata.merging(
                IncomesLogging.errorMetadata(error)
            ) { current, _ in
                current
            }
        )
    }
}

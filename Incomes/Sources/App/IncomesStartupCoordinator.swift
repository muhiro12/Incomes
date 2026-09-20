import AppIntents
import Foundation
import MHPlatform
import SwiftData

/// Builds the app's data environment and keeps startup recoverable when it fails.
@MainActor
@Observable
final class IncomesStartupCoordinator {
    /// Startup phase the scene renders.
    enum State {
        /// The data environment is available.
        case ready(IncomesPlatformEnvironment)
        /// The stored data could not be opened and needs explicit recovery.
        case recoveryRequired(IncomesStartupFailurePhase)
    }

    private(set) var state: State

    private let preferenceStore: MHPreferenceStore
    private let logging: MHLoggingBootstrap
    private let startupLogger: MHLogger

    init(
        preferenceStore: MHPreferenceStore,
        logging: MHLoggingBootstrap,
        startupLogger: MHLogger
    ) {
        self.preferenceStore = preferenceStore
        self.logging = logging
        self.startupLogger = startupLogger
        state = .recoveryRequired(.databaseMigration)
        state = makeState()
    }

    /// Repeats startup after a failure, without creating a second dataset.
    func retry() {
        startupLogger.notice("startup.retry_requested")
        state = makeState()
    }
}

private extension IncomesStartupCoordinator {
    func makeState() -> State {
        let isICloudEnabled = preferenceStore.bool(
            for: \.isICloudOn
        )
        startupLogger.notice(
            "platform_environment.build_requested",
            metadata: IncomesLogging.metadata(
                ("icloud_enabled", IncomesLogging.bool(isICloudEnabled))
            )
        )

        var failurePhase = IncomesStartupFailurePhase.databaseMigration
        do {
            startupLogger.notice("database_migration.begin")
            try IncomesStartupFailureSimulation.failIfRequested(phase: .databaseMigration)
            try DatabaseMigrator.migrateSQLiteFilesIfNeeded()
            startupLogger.notice("database_migration.completed")
            failurePhase = .modelContainer
            try IncomesStartupFailureSimulation.failIfRequested(phase: .modelContainer)
            let modelContainer = try IncomesPlatformEnvironmentFactory.makeAppModelContainer(
                isICloudEnabled: isICloudEnabled
            )
            startupLogger.notice("model_container.created")
            #if DEBUG
            try IncomesUISmokeLaunchSupport.prepareIfNeeded(
                modelContainer: modelContainer,
                logger: startupLogger
            )
            #endif
            let platformEnvironment = IncomesPlatformEnvironmentFactory.make(
                modelContainer: modelContainer,
                platformMode: .production,
                logging: logging
            )
            registerDependencies(platformEnvironment)
            startupLogger.notice("startup.ready")
            return .ready(platformEnvironment)
        } catch {
            logStartupFailure(
                error,
                phase: failurePhase,
                isICloudEnabled: isICloudEnabled
            )
            return .recoveryRequired(failurePhase)
        }
    }

    func registerDependencies(_ platformEnvironment: IncomesPlatformEnvironment) {
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

    func logStartupFailure(
        _ error: any Error,
        phase: IncomesStartupFailurePhase,
        isICloudEnabled: Bool
    ) {
        let startupFailureMetadata = IncomesLogging.metadata(
            ("phase", phase.loggingName),
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

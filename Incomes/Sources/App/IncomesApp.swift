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
    @State private var startupCoordinator: IncomesStartupCoordinator

    var body: some Scene {
        WindowGroup {
            switch startupCoordinator.state {
            case .ready(let platformEnvironment):
                IncomesAppRootView(
                    platformEnvironment: platformEnvironment
                )
            case .recoveryRequired(let phase):
                IncomesStartupRecoveryView(phase: phase) {
                    startupCoordinator.retry()
                }
            }
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

        _startupCoordinator = .init(
            wrappedValue: .init(
                preferenceStore: preferenceStore,
                logging: logging,
                startupLogger: startupLogger
            )
        )
        Self.recordCurrentAppVersion(
            preferenceStore: preferenceStore,
            startupLogger: startupLogger
        )
        IncomesShortcuts.updateAppShortcutParameters()
    }
}

private extension IncomesApp {
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
}

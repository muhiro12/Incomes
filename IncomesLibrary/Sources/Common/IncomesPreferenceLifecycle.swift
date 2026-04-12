import Foundation
import MHPlatformCore

/// Coordinates preference migration and cleanup for Incomes-owned AppStorage keys.
public enum IncomesPreferenceLifecycle {
    /// Persistent state descriptor used by the shared preference lifecycle service.
    public static let migrationStateDescriptor = MHPreferenceMigrationStateDescriptor(
        storageKey: "incomes.preferences.migration-state",
        defaultSelection: .standard
    )

    /// Runs the preference lifecycle synchronously before app-owned preference access begins.
    public static func runSynchronously(
        standardDomainName: String? = Bundle.main.bundleIdentifier
    ) -> MHPreferenceLifecycleOutcome {
        runSynchronously(
            descriptors: PreferenceDescriptorRegistry.allCases.map { descriptor in
                descriptor as any MHStorageDescriptorProtocol
            },
            migrationStateDescriptor: migrationStateDescriptor,
            standardDomainName: standardDomainName
        )
    }

    static func runSynchronously(
        descriptors: [any MHStorageDescriptorProtocol],
        migrationStateDescriptor: MHPreferenceMigrationStateDescriptor,
        standardDomainName: String? = Bundle.main.bundleIdentifier
    ) -> MHPreferenceLifecycleOutcome {
        let outcomeBox = PreferenceLifecycleOutcomeBox()

        Task.detached(priority: .userInitiated) {
            let outcome = await MHPreferenceLifecycleService.run(
                descriptors: descriptors,
                migrationStateDescriptor: migrationStateDescriptor,
                standardDomainName: standardDomainName
            )
            outcomeBox.store(outcome)
        }

        return outcomeBox.wait()
    }
}

private extension IncomesPreferenceLifecycle {
    enum PreferenceDescriptorRegistry: CaseIterable, MHStorageDescriptorProtocol {
        case isSubscribeOn
        case isICloudOn
        case isDebugOn
        case currencyCode
        case lastLaunchedAppVersion
        case notificationSettings

        var storageKey: String {
            storageDescriptor.storageKey
        }

        var defaultSelection: MHUserDefaultsSelection {
            storageDescriptor.defaultSelection
        }

        private var storageDescriptor: any MHStorageDescriptorProtocol {
            switch self {
            case .isSubscribeOn:
                BoolAppStorageKey.isSubscribeOn.preferenceDescriptor
            case .isICloudOn:
                BoolAppStorageKey.isICloudOn.preferenceDescriptor
            case .isDebugOn:
                BoolAppStorageKey.isDebugOn.preferenceDescriptor
            case .currencyCode:
                StringAppStorageKey.currencyCode.preferenceDescriptor
            case .lastLaunchedAppVersion:
                StringAppStorageKey.lastLaunchedAppVersion.preferenceDescriptor
            case .notificationSettings:
                NotificationSettingsAppStorageKey.notificationSettings.preferenceDescriptor
            }
        }

        func migrationSteps(
            store: MHPreferenceStore
        ) -> [MHPreferenceMigrationStep] {
            storageDescriptor.migrationSteps(store: store)
        }
    }

    final class PreferenceLifecycleOutcomeBox: @unchecked Sendable {
        private let lock = NSLock()
        private let semaphore = DispatchSemaphore(value: 0)
        private var outcome: MHPreferenceLifecycleOutcome?

        func store(
            _ outcome: MHPreferenceLifecycleOutcome
        ) {
            lock.lock()
            self.outcome = outcome
            lock.unlock()
            semaphore.signal()
        }

        func wait() -> MHPreferenceLifecycleOutcome {
            semaphore.wait()

            lock.lock()
            defer {
                lock.unlock()
            }

            guard let outcome else {
                preconditionFailure("Preference lifecycle did not produce an outcome.")
            }

            return outcome
        }
    }
}

import Foundation
import MHPlatformCore

/// Coordinates preference migration and cleanup for Incomes-owned preference descriptors.
public enum IncomesPreferenceLifecycle {
    /// Persistent state descriptor used by the shared preference lifecycle service.
    public static let migrationStateDescriptor = MHPreferenceMigrationStateDescriptor(
        storageKey: IncomesUserDefaultsKeys.Standard.preferenceMigrationState.rawValue,
        defaultSelection: .standard
    )

    /// Runs the preference lifecycle synchronously before app-owned preference access begins.
    public static func runSynchronously(
        standardDomainName: String? = Bundle.main.bundleIdentifier
    ) -> MHPreferenceLifecycleOutcome {
        runSynchronously(
            descriptors: currentDescriptors(),
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
    static func currentDescriptors() -> [any MHStorageDescriptorProtocol] {
        let descriptors = MHPreferenceDescriptors()
        return [
            descriptors.isSubscribeOn,
            descriptors.isICloudOn,
            descriptors.isDebugOn,
            descriptors.currencyCode,
            descriptors.lastLaunchedAppVersion,
            descriptors.notificationSettings
        ]
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

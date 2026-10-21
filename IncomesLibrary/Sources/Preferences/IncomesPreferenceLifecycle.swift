import Foundation
import MHPlatformCore

/// Coordinates preference migration and cleanup for Incomes-owned preference descriptors.
public enum IncomesPreferenceLifecycle {
    /// Persistent state descriptor used by the shared preference lifecycle service.
    public static let migrationStateDescriptor = MHPreferenceMigrationStateDescriptor(
        storageKey: IncomesUserDefaultsKeys.Standard.preferenceMigrationState.rawValue,
        defaultSelection: .standard
    )

    /// Complete current storage allowlist and migration-state slot for app startup.
    public static let registry = makeRegistry()

    /// Adds platform-owned storage to the startup allowlist without importing its SDKs.
    public static func makeRegistry(
        preserving additionalDescriptors: [MHRawStorageDescriptor] = []
    ) -> MHPreferenceRegistry {
        .init(
            descriptors: currentDescriptors() + additionalDescriptors,
            migrationStateDescriptor: migrationStateDescriptor
        )
    }

    /// Runs the preference lifecycle synchronously before app-owned preference access begins.
    public static func runSynchronously(
        standardDomainName: String? = Bundle.main.bundleIdentifier,
        preserving additionalDescriptors: [MHRawStorageDescriptor] = []
    ) -> MHPreferenceLifecycleOutcome {
        makeRegistry(preserving: additionalDescriptors).runSynchronously(
            standardDomainName: standardDomainName
        )
    }
}

private extension IncomesPreferenceLifecycle {
    /// Exact keys that StoreKit writes to the app's standard defaults domain.
    static let storeKitStorageKeys = [
        "SKSubscriptionStatusUpdatesLastChecked",
        "SKTransactionUpdatesLastChecked"
    ]

    static func currentDescriptors() -> [any MHStorageDescriptorProtocol] {
        let descriptors = MHPreferenceDescriptors()
        let appDescriptors: [any MHStorageDescriptorProtocol] = [
            descriptors.isSubscribeOn,
            descriptors.isICloudOn,
            descriptors.isDebugOn,
            descriptors.allowsUnverifiedEditing,
            descriptors.currencyCode,
            descriptors.lastLaunchedAppVersion,
            descriptors.notificationSettings,
            IncomesLogSnapshotStorage.descriptors.current,
            IncomesLogSnapshotStorage.descriptors.previous
        ]
        let externalDescriptors = storeKitStorageKeys.map { storageKey in
            MHRawStorageDescriptor(
                storageKey: storageKey,
                defaultSelection: .standard
            )
        }
        return appDescriptors + externalDescriptors
    }
}

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
    public static let registry = MHPreferenceRegistry(
        descriptors: currentDescriptors(),
        migrationStateDescriptor: migrationStateDescriptor
    )

    /// Runs the preference lifecycle synchronously before app-owned preference access begins.
    public static func runSynchronously(
        standardDomainName: String? = Bundle.main.bundleIdentifier
    ) -> MHPreferenceLifecycleOutcome {
        registry.runSynchronously(
            standardDomainName: standardDomainName
        )
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
}

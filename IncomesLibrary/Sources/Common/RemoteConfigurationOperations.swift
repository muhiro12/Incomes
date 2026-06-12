import Foundation

/// Domain operations for remote configuration decisions.
public enum RemoteConfigurationOperations {
    /// Returns whether the current app version is lower than the required version.
    public static func isUpdateRequired(
        currentVersion: String,
        requiredVersion: String
    ) -> Bool {
        VersionComparator.isUpdateRequired(
            current: currentVersion,
            required: requiredVersion
        )
    }
}

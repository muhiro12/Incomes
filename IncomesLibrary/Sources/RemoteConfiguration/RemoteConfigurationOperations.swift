import MHPlatformCore

/// Domain operations for remote configuration decisions.
public enum RemoteConfigurationOperations {
    /// Returns whether the current app version is lower than the required version.
    public static func isUpdateRequired(
        currentVersion: String,
        requiredVersion: String
    ) -> Bool {
        MHAppVersionComparison.numericStringsRequireUpdate(
            currentVersion: currentVersion,
            minimumVersion: requiredVersion
        )
    }
}

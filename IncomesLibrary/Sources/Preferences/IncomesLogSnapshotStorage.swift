import MHPlatformCore

/// Standard-domain slots for the bounded application log snapshots.
public enum IncomesLogSnapshotStorage {
    /// Current and previous session snapshot descriptors used by the logging bootstrap.
    public static let descriptors = MHLogSnapshotStorageDescriptors(
        current: .init(
            storageKey: IncomesUserDefaultsKeys.Standard.currentLogSnapshot.rawValue,
            defaultSelection: .standard
        ),
        previous: .init(
            storageKey: IncomesUserDefaultsKeys.Standard.previousLogSnapshot.rawValue,
            defaultSelection: .standard
        )
    )
}

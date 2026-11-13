import MHPlatformCore

/// Applies subscription access independently of the person's saved iCloud choice.
public enum SubscriptionStateOperations {
    /// Verification state reported by the subscription provider.
    public enum SubscriptionAccess: Sendable {
        case unknown
        case inactive
        case active
    }

    /// Persists resolved access and retains the last value while verification is unresolved.
    public static func updateSubscriptionAccess(
        _ access: SubscriptionAccess,
        store: MHPreferenceStore = .init()
    ) {
        switch access {
        case .unknown:
            return
        case .inactive:
            store.set(false, for: \.isSubscribeOn)
        case .active:
            store.set(true, for: \.isSubscribeOn)
        }
    }

    /// Resolves the next launch's sync configuration, not the currently open container's state.
    public static func isICloudEnabled(store: MHPreferenceStore = .init()) -> Bool {
        store.bool(for: \.isSubscribeOn) && store.bool(for: \.isICloudOn)
    }
}

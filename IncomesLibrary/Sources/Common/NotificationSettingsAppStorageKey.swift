import MHPreferences

public enum NotificationSettingsAppStorageKey: String {
    case notificationSettings = "A3b9Z1xQ"

    public var preferenceKey: MHStringPreferenceKey {
        .init(storageKey: rawValue)
    }
}

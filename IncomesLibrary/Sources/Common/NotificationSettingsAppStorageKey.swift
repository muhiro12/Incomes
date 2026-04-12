import MHPlatformCore

public enum NotificationSettingsAppStorageKey: String, CaseIterable, MHStringPrefDescriptorRepresentable {
    case notificationSettings = "A3b9Z1xQ"

    public var preferenceDescriptor: MHStringPreferenceDescriptor {
        .init(
            storageKey: rawValue,
            defaultSelection: .standard
        )
    }
}

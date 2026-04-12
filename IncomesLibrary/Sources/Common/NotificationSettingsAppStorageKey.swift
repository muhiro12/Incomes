import MHPlatformCore

public enum NotificationSettingsAppStorageKey: CaseIterable, MHStringPrefDescriptorRepresentable {
    case notificationSettings

    public var storageKey: String {
        switch self {
        case .notificationSettings:
            IncomesAppStorageKeys.Standard.notificationSettings.rawValue
        }
    }

    public var preferenceDescriptor: MHStringPreferenceDescriptor {
        .init(
            storageKey: storageKey,
            defaultSelection: .standard
        )
    }
}

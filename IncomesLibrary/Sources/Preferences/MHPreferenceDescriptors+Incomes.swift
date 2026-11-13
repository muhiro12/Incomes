import MHPlatformCore

/// App-owned preference descriptors backed by `UserDefaults`.
public extension MHPreferenceDescriptors {
    /// Explicit device-local permission to edit while update requirements are unavailable.
    var allowsUnverifiedEditing: MHBoolPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.allowsUnverifiedEditing.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// Last resolved subscription access, retained while verification is unresolved.
    var isSubscribeOn: MHBoolPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.isSubscribeOn.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// The person's saved iCloud choice, independent of subscription access and active configuration.
    var isICloudOn: MHBoolPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.isICloudOn.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// Debug mode preference persisted in the standard defaults domain.
    var isDebugOn: MHBoolPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.isDebugOn.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// Currency code preference persisted in the standard defaults domain.
    var currencyCode: MHStringPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.currencyCode.rawValue,
            defaultSelection: .standard
        )
    }

    /// Last launched app version persisted in the standard defaults domain.
    var lastLaunchedAppVersion: MHStringPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.lastLaunchedAppVersion.rawValue,
            defaultSelection: .standard
        )
    }

    /// Notification settings payload persisted in the standard defaults domain.
    var notificationSettings: MHStringPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.notificationSettings.rawValue,
            defaultSelection: .standard
        )
    }
}

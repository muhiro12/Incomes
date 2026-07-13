import MHPlatformCore

/// App-owned preference descriptors backed by `UserDefaults`.
public extension MHPreferenceDescriptors {
    /// Subscription state persisted in the standard defaults domain.
    var isSubscribeOn: MHBoolPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.isSubscribeOn.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// iCloud sync preference persisted in the standard defaults domain.
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

    /// Currency code shared by the app and its extensions through the App Group.
    var currencyCode: MHStringPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.AppGroup.currencyCode.rawValue,
            defaultSelection: .suite(AppGroup.id),
            legacySources: [
                .init(
                    storageKey: IncomesUserDefaultsKeys.Standard.currencyCode.rawValue,
                    selection: .standard
                )
            ]
        )
    }

    /// Pending deep link shared by app-owned processes through the App Group.
    var pendingDeepLinkURL: MHStringPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.AppGroup.pendingDeepLinkURL.rawValue,
            defaultSelection: .suite(AppGroup.id)
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

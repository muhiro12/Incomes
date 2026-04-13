import MHPlatformCore

/// App-owned preference descriptors backed by `UserDefaults`.
public extension MHPreferenceDescriptors {
    var isSubscribeOn: MHBoolPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.isSubscribeOn.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    var isICloudOn: MHBoolPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.isICloudOn.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    var isDebugOn: MHBoolPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.isDebugOn.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    var currencyCode: MHStringPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.currencyCode.rawValue,
            defaultSelection: .standard
        )
    }

    var lastLaunchedAppVersion: MHStringPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.lastLaunchedAppVersion.rawValue,
            defaultSelection: .standard
        )
    }

    var notificationSettings: MHStringPreferenceDescriptor {
        .init(
            storageKey: IncomesUserDefaultsKeys.Standard.notificationSettings.rawValue,
            defaultSelection: .standard
        )
    }
}

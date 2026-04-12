import MHPlatformCore

public enum BoolAppStorageKey: CaseIterable, MHBoolPrefDescriptorRepresentable {
    case isSubscribeOn
    case isICloudOn
    case isDebugOn

    public var storageKey: String {
        switch self {
        case .isSubscribeOn:
            IncomesAppStorageKeys.Standard.isSubscribeOn.rawValue
        case .isICloudOn:
            IncomesAppStorageKeys.Standard.isICloudOn.rawValue
        case .isDebugOn:
            IncomesAppStorageKeys.Standard.isDebugOn.rawValue
        }
    }

    public var preferenceDescriptor: MHBoolPreferenceDescriptor {
        .init(
            storageKey: storageKey,
            defaultSelection: .standard,
            default: false
        )
    }
}

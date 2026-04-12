import MHPlatformCore

public enum BoolAppStorageKey: String, CaseIterable, MHBoolPrefDescriptorRepresentable {
    case isSubscribeOn = "a018f613"
    case isICloudOn = "X7b9C4tZ"
    case isDebugOn = "a1B2c3D4"

    public var preferenceDescriptor: MHBoolPreferenceDescriptor {
        .init(
            storageKey: rawValue,
            defaultSelection: .standard,
            default: false
        )
    }
}

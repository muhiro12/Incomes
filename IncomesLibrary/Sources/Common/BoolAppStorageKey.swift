import MHPreferences

public enum BoolAppStorageKey: String {
    case isSubscribeOn = "a018f613"
    case isICloudOn = "X7b9C4tZ"
    case isDebugOn = "a1B2c3D4"

    public var preferenceKey: MHBoolPreferenceKey {
        .init(
            storageKey: rawValue,
            default: false
        )
    }
}

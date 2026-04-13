/// Central catalog of app-owned UserDefaults keys.
public enum IncomesUserDefaultsKeys {
    public enum Standard: String, CaseIterable {
        case isSubscribeOn = "a018f613"
        case isICloudOn = "X7b9C4tZ"
        case isDebugOn = "a1B2c3D4"
        case currencyCode = "R8k2Z3tL"
        case lastLaunchedAppVersion = "j4N7v2Qk"
        case notificationSettings = "A3b9Z1xQ"
        case preferenceMigrationState = "N6q1Lm8Z"
        case currentLogSnapshot = "c4R8m2Qx"
        case previousLogSnapshot = "p7V3k9Hs"
    }

    public enum AppGroup: String, CaseIterable {
        case pendingDeepLinkURL = "d2T9w4Bn"
    }
}

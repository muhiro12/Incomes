import Foundation

/// Documented for SwiftLint compliance.
public struct SubscriptionState {
    /// Documented for SwiftLint compliance.
    public let isSubscribeOn: Bool
    /// Documented for SwiftLint compliance.
    public let isICloudOn: Bool

    /// Documented for SwiftLint compliance.
    public init(
        isSubscribeOn: Bool,
        isICloudOn: Bool
    ) {
        self.isSubscribeOn = isSubscribeOn
        self.isICloudOn = isICloudOn
    }
}

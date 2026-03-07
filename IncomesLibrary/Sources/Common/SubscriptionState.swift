import Foundation

/// Combined subscription and iCloud availability state for premium features.
public struct SubscriptionState {
    /// True when the premium product is currently purchased.
    public let isSubscribeOn: Bool
    /// True when iCloud-backed features are enabled for the active subscription.
    public let isICloudOn: Bool

    /// Creates a subscription state snapshot.
    public init(
        isSubscribeOn: Bool,
        isICloudOn: Bool
    ) {
        self.isSubscribeOn = isSubscribeOn
        self.isICloudOn = isICloudOn
    }
}

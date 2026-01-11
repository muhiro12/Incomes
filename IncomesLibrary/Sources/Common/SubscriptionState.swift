import Foundation

public struct SubscriptionState {
    public let isSubscribeOn: Bool
    public let isICloudOn: Bool

    public init(
        isSubscribeOn: Bool,
        isICloudOn: Bool
    ) {
        self.isSubscribeOn = isSubscribeOn
        self.isICloudOn = isICloudOn
    }
}

public enum SubscriptionStateCalculator {
    public static func calculate(
        purchasedProductIDs: Set<String>,
        productID: String,
        isICloudOn: Bool
    ) -> SubscriptionState {
        let isSubscribeOn = purchasedProductIDs.contains(productID)
        let resolvedICloudOn = isSubscribeOn ? isICloudOn : false
        return .init(
            isSubscribeOn: isSubscribeOn,
            isICloudOn: resolvedICloudOn
        )
    }
}

/// Documented for SwiftLint compliance.
public enum SubscriptionStateCalculator {
    /// Documented for SwiftLint compliance.
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

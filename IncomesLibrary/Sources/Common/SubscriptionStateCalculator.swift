/// Resolves `SubscriptionState` from purchase and iCloud inputs.
public enum SubscriptionStateCalculator {
    /// Builds a subscription state for the given purchase set and iCloud toggle.
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

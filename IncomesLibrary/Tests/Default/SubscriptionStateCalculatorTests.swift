import Foundation
@testable import IncomesLibrary
import Testing

struct SubscriptionStateCalculatorTests {
    @Test
    func calculate_turns_off_iCloud_when_not_subscribed() {
        let state = SubscriptionStateCalculator.calculate(
            purchasedProductIDs: ["other.product"],
            productID: "com.example.product",
            isICloudOn: true
        )

        #expect(state.isSubscribeOn == false)
        #expect(state.isICloudOn == false)
    }

    @Test
    func calculate_keeps_iCloud_on_when_subscribed() {
        let state = SubscriptionStateCalculator.calculate(
            purchasedProductIDs: ["com.example.product"],
            productID: "com.example.product",
            isICloudOn: true
        )

        #expect(state.isSubscribeOn == true)
        #expect(state.isICloudOn == true)
    }

    @Test
    func calculate_keeps_iCloud_off_when_subscribed() {
        let state = SubscriptionStateCalculator.calculate(
            purchasedProductIDs: ["com.example.product"],
            productID: "com.example.product",
            isICloudOn: false
        )

        #expect(state.isSubscribeOn == true)
        #expect(state.isICloudOn == false)
    }
}

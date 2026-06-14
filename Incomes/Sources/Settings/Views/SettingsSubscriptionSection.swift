import SwiftUI
import TipKit

struct SettingsSubscriptionSection: View {
    let isSubscribeOn: Bool
    @Binding var isICloudOn: Bool
    let openSubscription: () -> Void

    private let subscriptionTip = SubscriptionTip()

    var body: some View {
        if isSubscribeOn {
            Section {
                Toggle(isOn: $isICloudOn) {
                    Text("iCloud On")
                }
            }
        } else {
            Section {
                SettingsNavigationRowButton(
                    title: "Subscription",
                    systemImage: "creditcard",
                    accessibilityHint: "Opens subscription settings.",
                    action: openSubscription
                )
                .popoverTip(subscriptionTip, arrowEdge: .top)
            }
        }
    }
}

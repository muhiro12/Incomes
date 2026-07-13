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
                    Text("iCloud Sync")
                }
            } footer: {
                Text("Restart Incomes to apply changes. The current iCloud sync setting remains active until then.")
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

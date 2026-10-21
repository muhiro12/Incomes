import SwiftUI
import TipKit

struct SettingsSubscriptionSection: View {
    let isSubscribeOn: Bool
    @Binding var isICloudOn: Bool
    let openSubscription: () -> Void

    private let subscriptionTip = SubscriptionTip()

    var body: some View {
        Section {
            Button(action: openSubscription) {
                Label("Subscription", systemImage: "creditcard")
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text("Opens subscription settings."))
            .popoverTip(isSubscribeOn ? nil : subscriptionTip, arrowEdge: .top)
            if isSubscribeOn {
                Toggle(isOn: $isICloudOn) {
                    Text("iCloud Sync")
                }
            }
        } footer: {
            if isSubscribeOn {
                Text(
                    "Restart Incomes to apply changes. The current iCloud sync setting remains active until then."
                )
            }
        }
    }
}

import StoreKit
import SwiftData
import SwiftUI
import TipKit

struct SettingsSubscriptionSection: View {
    @Environment(\.modelContext)
    private var context
    @Environment(\.openURL)
    private var openURL

    @State private var isPlanManagementPresented = false

    let isSubscribeOn: Bool
    @Binding var isICloudOn: Bool
    let openSubscription: () -> Void

    private let subscriptionTip = SubscriptionTip()

    var body: some View {
        Section {
            if isSubscribeOn {
                Button("Manage Plan", systemImage: "creditcard") {
                    managePlan()
                }
            } else {
                Button(action: openSubscription) {
                    Label("Subscription", systemImage: "creditcard")
                }
                .buttonStyle(.plain)
                .accessibilityHint(Text("Opens subscription settings."))
                .popoverTip(subscriptionTip, arrowEdge: .top)
            }
        }
        .manageSubscriptionsSheet(isPresented: $isPlanManagementPresented)

        #if !DEBUG
        SettingsICloudSection(
            isSubscribeOn: isSubscribeOn,
            isICloudOn: $isICloudOn,
            isICloudConfigured: isICloudConfigured
        )
        #endif
    }

    private var isICloudConfigured: Bool {
        context.container.configurations.contains { configuration in
            configuration.cloudKitContainerIdentifier != nil
        }
    }

    private func managePlan() {
        if ProcessInfo.processInfo.isiOSAppOnMac {
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                openURL(url)
            }
        } else {
            isPlanManagementPresented = true
        }
    }
}

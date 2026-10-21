import MHDesign
import MHPlatform
import SwiftUI

struct RemoteUpdateStatusView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics
    @AppStorage(\.allowsUnverifiedEditing)
    private var allowsUnverifiedEditing: Bool
    @State private var showsEditingSettings = false

    let decision: MHRemoteUpdateDecision
    let isLoading: Bool
    let retry: () -> Void
    let openStore: () -> Void

    var body: some View {
        Group {
            if decision != .notRequired {
                VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                    Text(title)
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                    HStack {
                        Button("Check Again") {
                            retry()
                        }
                        .disabled(isLoading)
                        Button("Open App Store") {
                            openStore()
                        }
                    }
                    .buttonStyle(.bordered)
                    if decision == .unavailable {
                        Button("Offline Editing") {
                            showsEditingSettings = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial)
                .accessibilityElement(children: .contain)
            }
        }
        .sheet(isPresented: $showsEditingSettings) {
            NavigationStack {
                RemoteUpdateEditingSettingsView()
                    .toolbar {
                        ToolbarItem {
                            CloseButton()
                        }
                    }
            }
        }
    }

    private var title: LocalizedStringKey {
        decision == .updateRequired ? "Update Required" : "Update Check Unavailable"
    }

    private var message: String {
        if decision == .unavailable, allowsUnverifiedEditing {
            return String(localized: "Editing is allowed without checking for updates.")
        }
        let error: RemoteUpdateError = decision == .updateRequired ? .updateRequired : .policyUnavailable
        return error.localizedDescription
    }
}

#Preview("Update required") {
    RemoteUpdateStatusView(
        decision: .updateRequired,
        isLoading: false,
        retry: RemoteUpdateStatusView.ignoreInteraction,
        openStore: RemoteUpdateStatusView.ignoreInteraction
    )
}

#Preview("Update check unavailable") {
    RemoteUpdateStatusView(
        decision: .unavailable,
        isLoading: false,
        retry: RemoteUpdateStatusView.ignoreInteraction,
        openStore: RemoteUpdateStatusView.ignoreInteraction
    )
}

private extension RemoteUpdateStatusView {
    static func ignoreInteraction() {
        // Previews must not start network requests or open the App Store.
    }
}

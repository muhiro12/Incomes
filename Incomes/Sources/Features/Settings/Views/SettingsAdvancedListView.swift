import MHPlatform
import SwiftData
import SwiftUI

struct SettingsAdvancedListView: View {
    @Environment(\.modelContext)
    private var context

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn: Bool

    @State private var model: SettingsScreenModel = .init()

    let navigateToRoute: (IncomesRoute) -> Void

    var body: some View {
        List {
            NavigationLink {
                RemoteUpdateEditingSettingsView()
            } label: {
                Label("Offline Editing", systemImage: "wifi.slash")
            }
            NavigationLink {
                SettingsMaintenanceList(
                    model: model,
                    canDeleteAll: canDeleteAllLedgers,
                    openDuplicateTags: {
                        navigateToRoute(.duplicateTags)
                    },
                    openOrphanTags: {
                        navigateToRoute(.orphanTags)
                    }
                )
            } label: {
                Label("Maintenance", systemImage: "wrench.and.screwdriver")
            }
            NavigationLink(value: SettingsNavigationDestination.debug) {
                Label("Debug", systemImage: "ladybug")
            }
            .accessibilityHint("Opens logs and read-only data inspection.")
        }
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await Task.yield()
            model.loadStatus(context: context)
        }
    }

    private var canDeleteAllLedgers: Bool {
        guard let ledgers = try? LedgerOperations.ledgers(context: context) else {
            return false
        }
        return ledgers.allSatisfy { LedgerAccessOperations.canEdit($0.id, isPremium: isSubscribeOn) }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        SettingsAdvancedListView { _ in
            // No route handling is needed in the preview.
        }
    }
}

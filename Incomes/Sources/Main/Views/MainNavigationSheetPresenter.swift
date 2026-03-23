import SwiftData
import SwiftUI

struct MainNavigationSheetPresenter: View {
    @Environment(\.modelContext)
    private var context

    let route: MainNavigationSheetRoute
    let itemDetailID: PersistentIdentifier?
    @Binding var settingsDestination: SettingsNavigationDestination?
    let onNavigateFromSettings: (IncomesRoute) -> Void

    var body: some View {
        switch route {
        case .settings:
            SettingsNavigationView(
                incomingDestination: $settingsDestination
            ) { route in
                onNavigateFromSettings(route)
            }
            .incomesSheetPresentation()
        case .yearlyDuplication:
            NavigationStack {
                YearlyDuplicationView()
            }
            .incomesSheetPresentation()
        case .itemDetail:
            deepLinkedItemNavigationView()
                .incomesSheetPresentation()
        }
    }
}

private extension MainNavigationSheetPresenter {
    @ViewBuilder
    func deepLinkedItemNavigationView() -> some View {
        if let itemDetailID,
           let item = try? context.fetchFirst(
            .items(.idIs(itemDetailID))
           ) {
            ItemNavigationView()
                .environment(item)
        } else {
            NavigationStack {
                ContentUnavailableView(
                    "Item Not Found",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("The selected item is no longer available.")
                )
                .navigationTitle("Item")
                .toolbar {
                    ToolbarItem {
                        CloseButton()
                    }
                }
            }
        }
    }
}

import SwiftData
import SwiftUI

struct MainNavigationSheetPresenter: View {
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    let route: MainNavigationSheetRoute
    @Binding var settingsDestination: SettingsNavigationDestination?
    let onNavigateFromSettings: (IncomesRoute) -> Void

    var body: some View {
        switch route {
        case .itemDetail(let itemID):
            MainNavigationItemDetailSheet(
                itemID: itemID,
                ledgerIdentifier: ledgerIdentifier
            )
        case .settings:
            SettingsNavigationView(
                incomingDestination: $settingsDestination
            ) { route in
                onNavigateFromSettings(route)
            }
            .incomesSheetPresentation()
        case .yearlyDuplication:
            NavigationStack {
                YearlyDuplicationView(ledgerIdentifier: ledgerIdentifier)
            }
            .incomesSheetPresentation()
        }
    }
}

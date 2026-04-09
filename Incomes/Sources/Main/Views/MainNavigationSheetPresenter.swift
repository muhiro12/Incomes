import SwiftData
import SwiftUI

struct MainNavigationSheetPresenter: View {
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
            MainNavigationItemDetailSheet(
                itemDetailID: itemDetailID
            )
            .incomesSheetPresentation()
        }
    }
}

import Foundation
@testable import Incomes
import Testing

@MainActor
struct MainNavigationSettingsCoordinatorTests {
    @Test
    func navigate_from_settings_queues_non_settings_route_until_dismissal() throws {
        let coordinator = MainNavigationSettingsCoordinator()
        var applied = false
        var dismissed = false
        var resolvedRoute: IncomesRoute?

        try coordinator.navigateFromSettings(
            to: .home,
            isSettingsPresented: true,
            applyRoute: {
                applied = true
            },
            dismissSettings: {
                dismissed = true
            }
        )

        #expect(applied == false)
        #expect(dismissed)

        try coordinator.applyPendingRouteAfterSettingsDismissalIfNeeded(
            isSettingsPresented: false
        ) { route in
            resolvedRoute = route
        }

        #expect(resolvedRoute == .home)
    }

    @Test
    func navigate_from_settings_applies_settings_scope_route_immediately() throws {
        let coordinator = MainNavigationSettingsCoordinator()
        var applied = false
        var dismissed = false

        try coordinator.navigateFromSettings(
            to: .settingsLicense,
            isSettingsPresented: true,
            applyRoute: {
                applied = true
            },
            dismissSettings: {
                dismissed = true
            }
        )

        #expect(applied)
        #expect(dismissed == false)
    }
}

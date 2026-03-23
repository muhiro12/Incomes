import Foundation

@MainActor
@Observable
final class MainNavigationSettingsCoordinator {
    private var pendingRouteAfterSettingsDismissal: IncomesRoute?

    func navigateFromSettings(
        to route: IncomesRoute,
        isSettingsPresented: Bool,
        applyRoute: () throws -> Void,
        dismissSettings: () -> Void
    ) throws {
        if isSettingsPresented, route.isSettingsScopeRoute {
            try applyRoute()
        } else if isSettingsPresented {
            pendingRouteAfterSettingsDismissal = route
            dismissSettings()
        } else {
            try applyRoute()
        }
    }

    func applyPendingRouteAfterSettingsDismissalIfNeeded(
        isSettingsPresented: Bool,
        applyRoute: (IncomesRoute) throws -> Void
    ) throws {
        guard isSettingsPresented == false,
              let pendingRouteAfterSettingsDismissal else {
            return
        }
        self.pendingRouteAfterSettingsDismissal = nil
        try applyRoute(pendingRouteAfterSettingsDismissal)
    }
}

extension IncomesRoute {
    var isSettingsScopeRoute: Bool {
        switch self {
        case .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug:
            return true
        case .home,
             .yearSummary,
             .yearlyDuplication,
             .duplicateTags,
             .year,
             .month,
             .item,
             .search:
            return false
        }
    }
}

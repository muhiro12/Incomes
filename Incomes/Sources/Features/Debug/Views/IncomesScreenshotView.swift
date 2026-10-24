#if DEBUG
import Foundation
import SwiftUI

/// Presents production navigation with a translated sample ledger and Premium appearance.
struct IncomesScreenshotView: View {
    private let platformEnvironment: IncomesPlatformEnvironment
    private let preferences: UserDefaults

    var body: some View {
        LedgerWorkspaceView()
            .incomesPreviewPlatformEnvironment(platformEnvironment)
            .defaultAppStorage(preferences)
            .preferredColorScheme(.light)
    }

    init() {
        do {
            platformEnvironment = try IncomesSampleData.makePreviewContext(profile: .standard)
        } catch {
            preconditionFailure("Failed to prepare screenshot data: \(error)")
        }

        let suiteName = "Incomes.Screenshots.\(ProcessInfo.processInfo.processIdentifier)"
        guard let preferences = UserDefaults(suiteName: suiteName) else {
            preconditionFailure("Failed to prepare screenshot preferences")
        }
        preferences.removePersistentDomain(forName: suiteName)
        preferences.set(true, forKey: IncomesUserDefaultsKeys.Standard.isSubscribeOn.rawValue)
        preferences.set(false, forKey: IncomesUserDefaultsKeys.Standard.isICloudOn.rawValue)
        preferences.set(false, forKey: IncomesUserDefaultsKeys.Standard.isDebugOn.rawValue)
        preferences.set("USD", forKey: IncomesUserDefaultsKeys.Standard.currencyCode.rawValue)
        self.preferences = preferences
    }
}
#endif

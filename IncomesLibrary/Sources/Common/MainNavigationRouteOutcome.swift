import Foundation
import SwiftData

/// Resolved outcome used to drive the app's main navigation state.
public enum MainNavigationRouteOutcome {
    /// Shows the main destination with an optional year tag and selected subtag.
    case destination(
            yearTagID: Tag.ID?,
            selectedTag: Tag?
         )
    /// Opens search with an optional prefilled query.
    case search(query: String?)
    /// Opens the settings root screen.
    case settings
    /// Opens the subscription settings screen.
    case settingsSubscription
    /// Opens the license settings screen.
    case settingsLicense
    /// Opens the debug settings screen.
    case settingsDebug
    /// Opens the yearly duplication flow.
    case yearlyDuplication
    /// Opens duplicate-tag management.
    case duplicateTags
    /// Opens the detail screen for the specified item.
    case itemDetail(itemID: PersistentIdentifier)
}

import Foundation
import SwiftData

/// Documented for SwiftLint compliance.
public enum MainNavigationRouteOutcome {
    /// Documented for SwiftLint compliance.
    case destination(
            yearTagID: Tag.ID?,
            selectedTag: Tag?
         )
    /// Documented for SwiftLint compliance.
    case search(query: String?)
    /// Documented for SwiftLint compliance.
    case settings
    /// Documented for SwiftLint compliance.
    case settingsSubscription
    /// Documented for SwiftLint compliance.
    case settingsLicense
    /// Documented for SwiftLint compliance.
    case settingsDebug
    /// Documented for SwiftLint compliance.
    case yearlyDuplication
    /// Documented for SwiftLint compliance.
    case duplicateTags
    /// Documented for SwiftLint compliance.
    case itemDetail(itemID: PersistentIdentifier)
}

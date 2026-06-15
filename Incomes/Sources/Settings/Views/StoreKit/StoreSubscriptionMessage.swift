import SwiftUI

enum StoreSubscriptionMessage {
    case loadFailed
    case purchaseCompleted
    case purchaseFailed
    case purchasePending
    case restoreRequested

    var text: LocalizedStringKey {
        switch self {
        case .loadFailed:
            "Unable to load subscription."
        case .purchaseCompleted:
            "Subscription updated."
        case .purchaseFailed:
            "Unable to complete purchase."
        case .purchasePending:
            "Purchase pending."
        case .restoreRequested:
            "Restore requested."
        }
    }

    var isFailure: Bool {
        switch self {
        case .loadFailed, .purchaseFailed:
            true
        case .purchaseCompleted, .purchasePending, .restoreRequested:
            false
        }
    }
}

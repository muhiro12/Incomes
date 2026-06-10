import Foundation
import SwiftData

/// Determines whether saving an item requires a repeat-scope decision.
enum ItemFormSaveDecision {
    /// True when saving `item` should ask whether to update one or multiple repeated items.
    static func requiresScopeSelection(
        context: ModelContext,
        item: Item
    ) throws -> Bool {
        try ItemQueryOperations.repeatItemsCount(
            context: context,
            repeatID: item.repeatID
        ) > 1
    }
}

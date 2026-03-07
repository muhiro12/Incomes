import Foundation
import SwiftData

/// Determines whether saving an item requires a repeat-scope decision.
public enum ItemFormSaveDecision {
    /// True when saving `item` should ask whether to update one or multiple repeated items.
    public static func requiresScopeSelection(
        context: ModelContext,
        item: Item
    ) throws -> Bool {
        try ItemService.repeatItemsCount(
            context: context,
            repeatID: item.repeatID
        ) > 1
    }
}

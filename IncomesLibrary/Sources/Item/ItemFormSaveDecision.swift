import Foundation
import SwiftData

/// Documented for SwiftLint compliance.
public enum ItemFormSaveDecision {
    /// Documented for SwiftLint compliance.
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

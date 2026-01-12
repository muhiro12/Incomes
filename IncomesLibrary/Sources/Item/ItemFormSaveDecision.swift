import Foundation
import SwiftData

public enum ItemFormSaveDecision {
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

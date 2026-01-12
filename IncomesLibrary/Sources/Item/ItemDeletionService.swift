import Foundation
import SwiftData

public enum ItemDeletionService {
    public static func resolveItemsForDeletion(
        from items: [Item],
        indices: IndexSet
    ) -> [Item] {
        indices.compactMap { index in
            items.indices.contains(index) ? items[index] : nil
        }
    }

    public static func delete(
        context: ModelContext,
        items: [Item]
    ) throws {
        try items.forEach { item in
            try ItemService.delete(context: context, item: item)
        }
    }
}

import Foundation

public enum TagItemDeletionResolver {
    public static func resolveItemsForDeletion(
        from tags: [Tag],
        indices: IndexSet
    ) -> [Item] {
        indices.flatMap { index -> [Item] in
            guard tags.indices.contains(index) else {
                return []
            }
            return tags[index].items.orEmpty
        }
    }
}

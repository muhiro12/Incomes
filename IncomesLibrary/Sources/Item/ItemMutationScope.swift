import Foundation

/// The scope of an item mutation when the target item belongs to a repeating series.
public enum ItemMutationScope: Sendable {
    case thisItem
    case futureItems
    case allItems
}

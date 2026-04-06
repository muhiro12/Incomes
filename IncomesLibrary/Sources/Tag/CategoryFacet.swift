import Foundation
import SwiftData

/// Logical category bucket used by user-facing category filters and suggestions.
public struct CategoryFacet: Identifiable, Hashable {
    public let id: String
    public let displayName: String
    public let storedNames: [String]
    public let itemIDs: [PersistentIdentifier]

    public init(
        id: String,
        displayName: String,
        storedNames: [String],
        itemIDs: [PersistentIdentifier]
    ) {
        self.id = id
        self.displayName = displayName
        self.storedNames = storedNames
        self.itemIDs = itemIDs
    }
}

public extension CategoryFacet {
    var count: Int {
        itemIDs.count
    }
}

/// Builds logical category buckets from mixed stored tag and item state.
public enum CategoryFacetService {
    public static func facets(
        tags: [Tag],
        items: [Item]
    ) -> [CategoryFacet] {
        let itemIDsByKey = Dictionary(grouping: items) { item in
            CategoryNameSupport.canonicalKey(
                forStoredName: item.category?.name
            )
        }
        .mapValues { groupedItems in
            groupedItems.map(\.id)
        }

        let storedNamesByKey = Dictionary(grouping: tags) { tag in
            CategoryNameSupport.canonicalKey(
                forStoredName: tag.name
            )
        }
        .mapValues { groupedTags in
            Array(Set(groupedTags.map(\.name)))
                .sorted()
        }

        let keys = Set(itemIDsByKey.keys)
            .union(storedNamesByKey.keys)

        return keys
            .map { key in
                let storedNames = storedNamesByKey[key].orEmpty
                let representativeName = storedNames.first
                return CategoryFacet(
                    id: key,
                    displayName: CategoryNameSupport.displayName(
                        forStoredName: representativeName
                    ),
                    storedNames: storedNames,
                    itemIDs: itemIDsByKey[key].orEmpty
                )
            }
            .sorted { lhs, rhs in
                let result = lhs.displayName.localizedStandardCompare(
                    rhs.displayName
                )
                if result != .orderedSame {
                    return result == .orderedAscending
                }

                return lhs.id < rhs.id
            }
    }

    public static func filteredFacets(
        tags: [Tag],
        items: [Item],
        query: String
    ) -> [CategoryFacet] {
        facets(tags: tags, items: items)
            .filter { facet in
                query.isEmpty || facet.displayName.normalizedContains(query)
            }
    }
}

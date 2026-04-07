import Foundation

/// Builds logical category buckets from mixed stored tag and item state.
public enum CategoryFacetService {
    /// Returns logical category buckets that merge uncategorized variants.
    public static func facets(
        tags: [Tag],
        items: [Item],
        othersDisplayName: String = CategoryNameSupport.localizedOthersDisplayName
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
                        forStoredName: representativeName,
                        othersDisplayName: othersDisplayName
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

    /// Returns logical category buckets filtered by a user-facing query.
    public static func filteredFacets(
        tags: [Tag],
        items: [Item],
        query: String,
        othersDisplayName: String = CategoryNameSupport.localizedOthersDisplayName
    ) -> [CategoryFacet] {
        facets(
            tags: tags,
            items: items,
            othersDisplayName: othersDisplayName
        )
        .filter { facet in
            query.isEmpty || matches(
                facet: facet,
                query: query,
                othersDisplayName: othersDisplayName
            )
        }
    }
}

private extension CategoryFacetService {
    static func matches(
        facet: CategoryFacet,
        query: String,
        othersDisplayName: String
    ) -> Bool {
        if facet.displayName.normalizedContains(query) {
            return true
        }

        if facet.storedNames.contains(where: { storedName in
            TagTextSupport.matchesStoredName(
                storedName,
                query: query
            )
        }) {
            return true
        }

        if facet.id == CategoryNameSupport.canonicalKey(forStoredName: nil) {
            return CategoryNameSupport.matchesOthersDisplayName(
                query: query,
                othersDisplayName: othersDisplayName
            )
        }

        return false
    }
}

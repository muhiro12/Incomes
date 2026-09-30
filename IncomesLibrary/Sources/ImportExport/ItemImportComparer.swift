import Foundation

/// Classifies file and store items with fixed rules, independent of input order.
enum ItemImportComparer {
    typealias StoreItem = ItemImportDifference.StoreItem
    typealias ChangeGroup = ItemImportDifference.ChangeGroup

    static func difference(
        fileItems: [IncomesFileItem],
        storeItems: [StoreItem]
    ) -> ItemImportDifference {
        let orderedFileItems = IncomesFileItem.sortedByValue(fileItems)
        let orderedStoreItems = sortedStoreItems(storeItems)

        // Equal items are interchangeable, so matching the first ones in a fixed order is exact.
        let matchedCounts = matchedCountsByKey(
            fileItems: orderedFileItems,
            storeItems: orderedStoreItems
        )
        let unmatchedFileItems = unmatched(
            orderedFileItems,
            matchedCounts: matchedCounts
        ) { item in
            ItemImportMatchKey(item)
        }
        let unmatchedStoreItems = unmatched(
            orderedStoreItems,
            matchedCounts: matchedCounts
        ) { storeItem in
            ItemImportMatchKey(storeItem.item)
        }

        let fileGroups = Dictionary(grouping: unmatchedFileItems) { item in
            groupID(for: item)
        }
        let storeGroups = Dictionary(grouping: unmatchedStoreItems) { storeItem in
            groupID(for: storeItem.item)
        }
        let changeGroupIDs = Set(fileGroups.keys).intersection(storeGroups.keys)

        return .init(
            matchedCount: matchedCounts.values.reduce(.zero, +),
            changeGroups: sortedGroupIDs(changeGroupIDs).map { id in
                .init(
                    id: id,
                    fileItems: fileGroups[id] ?? [],
                    storeItems: storeGroups[id] ?? []
                )
            },
            additions: unmatchedFileItems.filter { item in
                !changeGroupIDs.contains(groupID(for: item))
            },
            storeOnlyItems: unmatchedStoreItems.filter { storeItem in
                !changeGroupIDs.contains(groupID(for: storeItem.item))
            },
            storeItemCount: storeItems.count,
            reviewedStoreItems: orderedStoreItems
        )
    }
}

private extension ItemImportComparer {
    static func sortedStoreItems(_ storeItems: [StoreItem]) -> [StoreItem] {
        storeItems.sorted { left, right in
            if left.item != right.item {
                return left.item.isOrderedByValue(before: right.item)
            }
            return String(describing: left.id) < String(describing: right.id)
        }
    }

    static func matchedCountsByKey(
        fileItems: [IncomesFileItem],
        storeItems: [StoreItem]
    ) -> [ItemImportMatchKey: Int] {
        let fileCounts = counts(of: fileItems.map(ItemImportMatchKey.init))
        let storeCounts = counts(of: storeItems.map { storeItem in
            ItemImportMatchKey(storeItem.item)
        })
        return fileCounts.reduce(into: [:]) { result, entry in
            let matchedCount = min(entry.value, storeCounts[entry.key] ?? .zero)
            if matchedCount > .zero {
                result[entry.key] = matchedCount
            }
        }
    }

    static func counts(of keys: [ItemImportMatchKey]) -> [ItemImportMatchKey: Int] {
        keys.reduce(into: [:]) { result, key in
            result[key, default: .zero] += 1
        }
    }

    static func unmatched<Element>(
        _ elements: [Element],
        matchedCounts: [ItemImportMatchKey: Int],
        key: (Element) -> ItemImportMatchKey
    ) -> [Element] {
        var remainingMatches = matchedCounts
        return elements.filter { element in
            let elementKey = key(element)
            guard let remaining = remainingMatches[elementKey],
                  remaining > .zero else {
                return true
            }
            remainingMatches[elementKey] = remaining - 1
            return false
        }
    }

    static func groupID(for item: IncomesFileItem) -> ItemImportChangeGroupKey {
        .init(date: item.date, content: item.content)
    }

    static func sortedGroupIDs(_ ids: Set<ItemImportChangeGroupKey>) -> [ItemImportChangeGroupKey] {
        ids.sorted { left, right in
            if left.date != right.date {
                return left.date < right.date
            }
            return left.content < right.content
        }
    }
}

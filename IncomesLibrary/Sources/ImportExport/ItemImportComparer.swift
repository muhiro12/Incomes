import Foundation

/// Classifies file and store items with fixed rules, independent of input order.
enum ItemImportComparer {
    typealias StoreItem = ItemImportDifference.StoreItem
    typealias ChangeGroup = ItemImportDifference.ChangeGroup

    private struct ExactMatchKey: Hashable {
        let values: ItemImportMatchKey
        let repeatID: UUID
        let balance: Decimal?

        init(_ item: IncomesFileItem) {
            values = .init(item)
            repeatID = item.repeatID
            balance = item.balance
        }
    }

    static func difference(
        fileItems: [IncomesFileItem],
        storeItems: [StoreItem]
    ) -> ItemImportDifference {
        let orderedFileItems = IncomesFileItem.sortedByValue(fileItems)
        let orderedStoreItems = sortedStoreItems(storeItems)

        // Prefer complete matches so duplicate transactions keep the correct saved balance.
        let exactCounts = matchedCountsByKey(
            fileKeys: orderedFileItems.map(ExactMatchKey.init),
            storeKeys: orderedStoreItems.map { ExactMatchKey($0.item) }
        )
        let remainingFileItems = unmatched(orderedFileItems, matchedCounts: exactCounts, key: ExactMatchKey.init)
        let remainingStoreItems = unmatched(orderedStoreItems, matchedCounts: exactCounts) { ExactMatchKey($0.item) }
        let matchedCounts = matchedCountsByKey(
            fileKeys: remainingFileItems.map(ItemImportMatchKey.init),
            storeKeys: remainingStoreItems.map { ItemImportMatchKey($0.item) }
        )
        let unmatchedFileItems = unmatched(
            remainingFileItems,
            matchedCounts: matchedCounts
        ) { item in
            ItemImportMatchKey(item)
        }
        let unmatchedStoreItems = unmatched(
            remainingStoreItems,
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
            matchedCount: exactCounts.values.reduce(.zero, +) + matchedCounts.values.reduce(.zero, +),
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

    static func matchedCountsByKey<Key: Hashable>(fileKeys: [Key], storeKeys: [Key]) -> [Key: Int] {
        let fileCounts = counts(of: fileKeys)
        let storeCounts = counts(of: storeKeys)
        return fileCounts.reduce(into: [:]) { result, entry in
            let matchedCount = min(entry.value, storeCounts[entry.key] ?? .zero)
            if matchedCount > .zero {
                result[entry.key] = matchedCount
            }
        }
    }

    static func counts<Key: Hashable>(of keys: [Key]) -> [Key: Int] {
        keys.reduce(into: [:]) { result, key in
            result[key, default: .zero] += 1
        }
    }

    static func unmatched<Element, Key: Hashable>(
        _ elements: [Element],
        matchedCounts: [Key: Int],
        key: (Element) -> Key
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
        .init(date: item.date, content: item.content, ledgerIdentifier: item.ledgerIdentifier)
    }

    static func sortedGroupIDs(_ ids: Set<ItemImportChangeGroupKey>) -> [ItemImportChangeGroupKey] {
        ids.sorted { left, right in
            if left.ledgerIdentifier != right.ledgerIdentifier {
                return left.ledgerIdentifier.rawValue < right.ledgerIdentifier.rawValue
            }
            if left.date != right.date {
                return left.date < right.date
            }
            return left.content < right.content
        }
    }
}

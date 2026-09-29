import SwiftData

/// Items a reviewed difference and policy insert and remove.
struct ItemImportPlan {
    let insertedItems: [IncomesFileItem]
    let removedItemIDs: Set<PersistentIdentifier>
    let result: ItemImportResult
}

extension ItemImportPlan {
    init(
        difference: ItemImportDifference,
        policy: ItemImportPolicy
    ) {
        var insertedItems = [IncomesFileItem]()
        var removedItems = [ItemImportDifference.StoreItem]()
        switch policy {
        case .replace:
            insertedItems = difference.additions
            removedItems = difference.storeOnlyItems
            for group in difference.changeGroups {
                insertedItems += group.fileItems
                removedItems += group.storeItems
            }
        case .merge(let decisions):
            insertedItems = difference.additions.enumerated().compactMap { index, item in
                decisions.excludedAdditionIndices.contains(index) ? nil : item
            }
            for group in difference.changeGroups {
                switch decisions.resolution(for: group.id) {
                case .keepCurrent:
                    break
                case .useFile:
                    insertedItems += group.fileItems
                    removedItems += group.storeItems
                case .keepBoth:
                    insertedItems += group.fileItems
                }
            }
        }
        self.init(
            insertedItems: insertedItems,
            removedItemIDs: Set(removedItems.map(\.id)),
            result: .init(
                addedCount: insertedItems.count,
                removedCount: removedItems.count,
                unchangedCount: difference.matchedCount
            )
        )
    }
}

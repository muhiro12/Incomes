import Foundation
@testable import IncomesLibrary
import SwiftData

/// Stored values and both relationship directions, including native model identity.
struct MutationStoreSnapshot: Equatable {
    struct ItemState: Equatable {
        let value: IncomesFileItem
        let tagIDs: Set<String>
    }

    struct TagState: Equatable {
        let name: String
        let typeID: String
        let itemIDs: Set<String>
    }

    let items: [String: ItemState]
    let tags: [String: TagState]

    init(context: ModelContext) throws {
        items = try Dictionary(uniqueKeysWithValues: context.fetch(.allLedgerItems()).map { item in
            (
                try PersistentIdentifierCoder.encode(item.id),
                ItemState(
                    value: .init(item: item, derivedBalance: item.balance),
                    tagIDs: try Set((item.tags ?? []).map { try PersistentIdentifierCoder.encode($0.id) })
                )
            )
        })
        tags = try Dictionary(uniqueKeysWithValues: context.fetch(.tags(.all)).map { tag in
            (
                try PersistentIdentifierCoder.encode(tag.id),
                TagState(
                    name: tag.name,
                    typeID: tag.typeID,
                    itemIDs: try Set((tag.items ?? []).map { try PersistentIdentifierCoder.encode($0.id) })
                )
            )
        })
    }
}

import Foundation
import SwiftData

/// A live Item query whose ledger membership is resolved from the actual Tag graph.
public struct ItemFetchDescriptor {
    /// Store-level candidates; apply `results(from:)` before displaying or using them.
    public let candidateDescriptor: FetchDescriptor<Item>
    /// Maximum results after ledger filtering. Nil returns every matching Item.
    public var fetchLimit: Int?

    private let ledgerIdentifier: LedgerIdentifier

    /// Builds a sorted query within one ledger, excluding conflicting memberships.
    public static func items(
        _ predicate: ItemPredicate,
        order: SortOrder = .reverse,
        ledgerIdentifier: LedgerIdentifier = .default
    ) -> Self {
        let base = predicate.value
        let reserved = TagType.ledger.rawValue
        let isDefault = ledgerIdentifier == .default
        let scope = #Predicate<Item> { item in
            (item.tags?.contains { tag in tag.typeID == reserved } ?? false) != isDefault
        }
        return .init(
            candidateDescriptor: .init(
                predicate: #Predicate { item in
                    scope.evaluate(item) && base.evaluate(item)
                },
                sortBy: [
                    .init(\.date, order: order),
                    .init(\.priority, order: order == .forward ? .reverse : .forward),
                    .init(\.content, order: order),
                    .init(\.persistentModelID, order: order)
                ]
            ),
            ledgerIdentifier: ledgerIdentifier
        )
    }

    /// Filters the current live graph before applying a limit or choosing the first Item.
    public func results(from candidates: [Item]) -> [Item] {
        guard ledgerIdentifier != .conflicting else {
            return []
        }
        // iOS 18 can return another ledger's Items for a nested Tag ID comparison.
        // Keep identity comparisons on the live graph, independent of store row numbers.
        let scoped = candidates.filter { $0.ledgerIdentifier == ledgerIdentifier }
        guard let fetchLimit else {
            return scoped
        }
        return Array(scoped.prefix(max(fetchLimit, .zero)))
    }
}

extension ModelContext {
    func fetch(_ descriptor: ItemFetchDescriptor) throws -> [Item] {
        descriptor.results(from: try fetch(descriptor.candidateDescriptor))
    }

    func fetchCount(_ descriptor: ItemFetchDescriptor) throws -> Int {
        try fetch(descriptor).count
    }

    func fetchFirst(_ descriptor: ItemFetchDescriptor) throws -> Item? {
        var descriptor = descriptor
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }
}

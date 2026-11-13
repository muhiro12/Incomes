import Foundation
import SwiftData

/// Incomes' financial sequence, shared by native queries and in-memory projections.
enum ItemOrdering {
    static let contentComparator = String.StandardComparator.localizedStandard

    static func descriptors(order: SortOrder) -> [SortDescriptor<Item>] {
        descriptors(
            date: \.date,
            priority: \.priority,
            content: \.content,
            identity: \.persistentModelID,
            order: order
        )
    }

    static func descriptors<Value, Identity: Comparable>(
        date: KeyPath<Value, Date> & Sendable,
        priority: KeyPath<Value, Int> & Sendable,
        content: KeyPath<Value, String> & Sendable,
        identity: KeyPath<Value, Identity> & Sendable,
        order: SortOrder = .forward
    ) -> [SortDescriptor<Value>] {
        [
            .init(date, order: order),
            .init(priority, order: order == .forward ? .reverse : .forward),
            .init(content, comparator: contentComparator, order: order),
            .init(identity, order: order)
        ]
    }
}

import Foundation
import SwiftData

/// Domain operations for querying `Item` models.
public enum ItemQueryOperations {
    /// Returns total number of items.
    public static func allItemsCount(
        context: ModelContext,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> Int {
        try context.fetchCount(.items(.all, ledgerIdentifier: ledgerIdentifier))
    }

    /// Returns all items in the store.
    public static func items(
        context: ModelContext,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> [Item] {
        try context.fetch(.items(.all, ledgerIdentifier: ledgerIdentifier))
    }

    /// Returns number of items in the same repeat series.
    public static func repeatItemsCount(
        context: ModelContext,
        repeatID: UUID,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> Int {
        try context.fetchCount(.items(.repeatIDIs(repeatID), ledgerIdentifier: ledgerIdentifier))
    }

    /// Returns number of items in the year containing `date`.
    public static func yearItemsCount(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> Int {
        try context.fetchCount(.items(.dateIsSameYearAs(date), ledgerIdentifier: ledgerIdentifier))
    }

    /// Returns items within the month containing `date`.
    public static func items(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> [Item] {
        try context.fetch(
            .items(.dateIsSameMonthAs(date), ledgerIdentifier: ledgerIdentifier)
        )
    }

    /// Returns an item matching a Base64-encoded persistent identifier.
    public static func item(
        context: ModelContext,
        encodedIdentifier: String
    ) throws -> Item? {
        let identifier = try PersistentIdentifierCoder.decode(encodedIdentifier)
        return try item(context: context, persistentID: identifier)
    }

    /// Returns an item matching a persistent identifier.
    public static func item(
        context: ModelContext,
        persistentID: PersistentIdentifier
    ) throws -> Item? {
        try context.fetchFirst(.init(predicate: ItemPredicate.idIs(persistentID).value))
    }

    /// Returns items matching Base64-encoded persistent identifiers.
    public static func items(
        context: ModelContext,
        encodedIdentifiers: [String]
    ) throws -> [Item] {
        let identifiers = try encodedIdentifiers.map(PersistentIdentifierCoder.decode)
        var descriptor = FetchDescriptor<Item>.allLedgerItems()
        descriptor.predicate = ItemPredicate.idsAre(identifiers).value
        return try context.fetch(descriptor)
    }

    /// Returns items whose content contains `string`.
    public static func items(
        context: ModelContext,
        matchingContent string: String,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> [Item] {
        try context.fetch(
            .items(.contentContains(string), ledgerIdentifier: ledgerIdentifier)
        )
    }

    /// Returns the next item on or after `date`.
    public static func nextItem(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> Item? {
        try nextItemModel(context: context, date: date, ledgerIdentifier: ledgerIdentifier)
    }

    /// Returns the previous item on or before `date`.
    public static func previousItem(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> Item? {
        try previousItemModel(context: context, date: date, ledgerIdentifier: ledgerIdentifier)
    }

    /// Returns all items that occur on the same local day as the next item after `date`.
    public static func nextItems(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> [Item] {
        guard let item = try nextItemModel(context: context, date: date, ledgerIdentifier: ledgerIdentifier) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate), ledgerIdentifier: ledgerIdentifier)
        )
    }

    /// Returns all items that occur on the same local day as the previous item before `date`.
    public static func previousItems(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> [Item] {
        guard let item = try previousItemModel(context: context, date: date, ledgerIdentifier: ledgerIdentifier) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate), ledgerIdentifier: ledgerIdentifier)
        )
    }
}

private extension ItemQueryOperations {
    static func nextItemModel(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier
    ) throws -> Item? {
        let descriptor = FetchDescriptor.items(
            .dateIsAfter(date),
            order: .forward,
            ledgerIdentifier: ledgerIdentifier
        )
        return try context.fetchFirst(descriptor)
    }

    static func previousItemModel(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier
    ) throws -> Item? {
        let descriptor = FetchDescriptor.items(.dateIsBefore(date), ledgerIdentifier: ledgerIdentifier)
        return try context.fetchFirst(descriptor)
    }
}

import Foundation
import SwiftData

/// Domain operations for querying `Item` models.
public enum ItemQueryOperations {
    /// Returns total number of items.
    public static func allItemsCount(context: ModelContext) throws -> Int {
        try context.fetchCount(.items(.all))
    }

    /// Returns number of items in the same repeat series.
    public static func repeatItemsCount(context: ModelContext, repeatID: UUID) throws -> Int {
        try context.fetchCount(.items(.repeatIDIs(repeatID)))
    }

    /// Returns number of items in the year containing `date`.
    public static func yearItemsCount(context: ModelContext, date: Date) throws -> Int {
        try context.fetchCount(.items(.dateIsSameYearAs(date)))
    }

    /// Returns items within the month containing `date`.
    public static func items(context: ModelContext, date: Date) throws -> [Item] {
        try context.fetch(
            .items(.dateIsSameMonthAs(date))
        )
    }

    /// Returns the next item on or after `date`.
    public static func nextItem(context: ModelContext, date: Date) throws -> Item? {
        try nextItemModel(context: context, date: date)
    }

    /// Returns the previous item on or before `date`.
    public static func previousItem(context: ModelContext, date: Date) throws -> Item? {
        try previousItemModel(context: context, date: date)
    }

    /// Returns all items that occur on the same local day as the next item after `date`.
    public static func nextItems(context: ModelContext, date: Date) throws -> [Item] {
        guard let item = try nextItemModel(context: context, date: date) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate))
        )
    }

    /// Returns all items that occur on the same local day as the previous item before `date`.
    public static func previousItems(context: ModelContext, date: Date) throws -> [Item] {
        guard let item = try previousItemModel(context: context, date: date) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate))
        )
    }

    /// Returns the local date of the next item after `date`.
    public static func nextItemDate(context: ModelContext, date: Date) throws -> Date? {
        try nextItemModel(context: context, date: date)?.localDate
    }

    /// Returns the local date of the previous item before `date`.
    public static func previousItemDate(context: ModelContext, date: Date) throws -> Date? {
        try previousItemModel(context: context, date: date)?.localDate
    }

    /// Convenience: returns the content of the next item after `date`.
    public static func nextItemContent(context: ModelContext, date: Date) throws -> String? {
        try nextItemModel(context: context, date: date)?.content
    }

    /// Convenience: returns the content of the previous item before `date`.
    public static func previousItemContent(context: ModelContext, date: Date) throws -> String? {
        try previousItemModel(context: context, date: date)?.content
    }
}

private extension ItemQueryOperations {
    static func nextItemModel(
        context: ModelContext,
        date: Date
    ) throws -> Item? {
        let descriptor = FetchDescriptor.items(
            .dateIsAfter(date),
            order: .forward
        )
        return try context.fetchFirst(descriptor)
    }

    static func previousItemModel(
        context: ModelContext,
        date: Date
    ) throws -> Item? {
        let descriptor = FetchDescriptor.items(.dateIsBefore(date))
        return try context.fetchFirst(descriptor)
    }
}

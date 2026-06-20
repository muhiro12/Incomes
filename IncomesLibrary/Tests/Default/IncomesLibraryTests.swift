// swiftlint:disable prefixed_toplevel_constant

import Foundation
@testable import IncomesLibrary
import SwiftData

var testContext: ModelContext {
    do {
        return .init(
            try .init(
                for: Item.self,
                configurations: .init(
                    isStoredInMemoryOnly: true
                )
            )
        )
    } catch {
        preconditionFailure("Failed to create test context: \(error)")
    }
}

@MainActor let isoDate: (String) -> Date = { string in
    guard let date = ISO8601DateFormatter().date(from: string) else {
        preconditionFailure("Invalid ISO8601 date string: \(string)")
    }
    return date
}

@MainActor let shiftedDate: (String) -> Date = { string in
    Calendar.current.shiftedDate(
        componentsFrom: isoDate(string),
        in: .utc
    )
}

let timeZones: [TimeZone] = [
    timeZone(identifier: "Asia/Tokyo"),
    timeZone(identifier: "Europe/London"),
    timeZone(identifier: "America/New_York"),
    timeZone(identifier: "America/Santo_Domingo"),
    timeZone(identifier: "Europe/Minsk")
]

func fetchItems(_ context: ModelContext) -> [Item] {
    do {
        return try context.fetch(.items(.all))
    } catch {
        preconditionFailure("Failed to fetch test items: \(error)")
    }
}

@discardableResult
func createItem(
    context: ModelContext,
    input: ItemFormInput,
    repeatCount: Int = 1
) throws -> Item {
    try ItemCreationOperations.create(
        context: context,
        input: input,
        repeatCount: repeatCount
    )
}

@discardableResult
func createItem(
    context: ModelContext,
    input: ItemFormInput,
    repeatMonthSelections: Set<RepeatMonthSelection>
) throws -> Item {
    try ItemCreationOperations.create(
        context: context,
        input: input,
        repeatMonthSelections: repeatMonthSelections
    )
}

func updateItem(
    context: ModelContext,
    item: Item,
    input: ItemFormInput,
    scope: ItemMutationScope = .thisItem
) throws {
    try ItemUpdateOperations.update(
        context: context,
        item: item,
        input: input,
        scope: scope
    )
}

func updateAllItems(
    context: ModelContext,
    item: Item,
    input: ItemFormInput
) throws {
    try updateItem(
        context: context,
        item: item,
        input: input,
        scope: .allItems
    )
}

func updateFutureItems(
    context: ModelContext,
    item: Item,
    input: ItemFormInput
) throws {
    try updateItem(
        context: context,
        item: item,
        input: input,
        scope: .futureItems
    )
}

private func timeZone(identifier: String) -> TimeZone {
    guard let timeZone = TimeZone(identifier: identifier) else {
        preconditionFailure("Invalid time zone identifier: \(identifier)")
    }
    return timeZone
}
// swiftlint:enable prefixed_toplevel_constant

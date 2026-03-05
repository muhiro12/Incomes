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

// swiftlint:disable:next prefixed_toplevel_constant
@MainActor let isoDate: (String) -> Date = { string in
    guard let date = ISO8601DateFormatter().date(from: string) else {
        preconditionFailure("Invalid ISO8601 date string: \(string)")
    }
    return date
}

// swiftlint:disable:next prefixed_toplevel_constant
@MainActor let shiftedDate: (String) -> Date = { string in
    Calendar.current.shiftedDate(
        componentsFrom: isoDate(string),
        in: .utc
    )
}

// swiftlint:disable:next prefixed_toplevel_constant
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

private func timeZone(identifier: String) -> TimeZone {
    guard let timeZone = TimeZone(identifier: identifier) else {
        preconditionFailure("Invalid time zone identifier: \(identifier)")
    }
    return timeZone
}

func makeItemFormInput(
    date: Date,
    content: String,
    income: Decimal,
    outgo: Decimal,
    category: String,
    priority: Int
) -> ItemFormInput {
    .init(
        date: date,
        content: content,
        incomeText: income.description,
        outgoText: outgo.description,
        category: category,
        priorityText: "\(priority)"
    )
}

@discardableResult
func createItem(
    context: ModelContext,
    date: Date,
    content: String,
    income: Decimal,
    outgo: Decimal,
    category: String,
    priority: Int,
    repeatCount: Int = 1
) throws -> Item {
    try ItemService.create(
        context: context,
        input: makeItemFormInput(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority
        ),
        repeatCount: repeatCount
    )
}

@discardableResult
func createItem(
    context: ModelContext,
    date: Date,
    content: String,
    income: Decimal,
    outgo: Decimal,
    category: String,
    priority: Int,
    repeatMonthSelections: Set<RepeatMonthSelection>
) throws -> Item {
    try ItemService.create(
        context: context,
        input: makeItemFormInput(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority
        ),
        repeatMonthSelections: repeatMonthSelections
    )
}

func updateItem(
    context: ModelContext,
    item: Item,
    date: Date,
    content: String,
    income: Decimal,
    outgo: Decimal,
    category: String,
    priority: Int,
    scope: ItemMutationScope = .thisItem
) throws {
    try ItemService.update(
        context: context,
        item: item,
        input: makeItemFormInput(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority
        ),
        scope: scope
    )
}

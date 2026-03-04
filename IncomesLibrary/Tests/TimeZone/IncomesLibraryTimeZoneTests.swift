import Foundation
@testable import IncomesLibrary
import SwiftData

var testContext: ModelContext {
    .init(
        try! .init(
            for: Item.self,
            configurations: .init(
                isStoredInMemoryOnly: true
            )
        )
    )
}

@MainActor
let isoDate: (String) -> Date = { string in
    guard let date = ISO8601DateFormatter().date(from: string) else {
        preconditionFailure("Invalid ISO8601 date string: \(string)")
    }
    return date
}

@MainActor
let shiftedDate: (String) -> Date = { string in
    Calendar.current.shiftedDate(
        componentsFrom: isoDate(string),
        in: .utc
    )
}

let timeZones: [TimeZone] = [
    .init(identifier: "Asia/Tokyo")!,
    .init(identifier: "Europe/London")!,
    .init(identifier: "America/New_York")!,
    .init(identifier: "America/Santo_Domingo")!,
    .init(identifier: "Europe/Minsk")!
]

func fetchItems(_ context: ModelContext) -> [Item] {
    try! context.fetch(.items(.all))
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

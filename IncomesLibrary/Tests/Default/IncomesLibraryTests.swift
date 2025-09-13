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

@preconcurrency
nonisolated(unsafe) func isoDate(_ string: String) -> Date {
    guard let date = ISO8601DateFormatter().date(from: string) else {
        preconditionFailure("Invalid ISO8601 date string: \(string)")
    }
    return date
}

@preconcurrency
nonisolated(unsafe) func shiftedDate(_ string: String) -> Date {
    Calendar.current.shiftedDate(
        componentsFrom: isoDate(string),
        in: .utc
    )
}

nonisolated(unsafe) let timeZones: [TimeZone] = [
    .init(identifier: "Asia/Tokyo")!,
    .init(identifier: "Europe/London")!,
    .init(identifier: "America/New_York")!,
    .init(identifier: "America/Santo_Domingo")!,
    .init(identifier: "Europe/Minsk")!
]

func fetchItems(_ context: ModelContext) -> [Item] {
    try! context.fetch(.items(.all))
}

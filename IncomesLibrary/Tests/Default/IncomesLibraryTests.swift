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

@MainActor let isoDate: (String) -> Date = { string in // swiftlint:disable:this prefixed_toplevel_constant
    guard let date = ISO8601DateFormatter().date(from: string) else {
        preconditionFailure("Invalid ISO8601 date string: \(string)")
    }
    return date
}

@MainActor let shiftedDate: (String) -> Date = { string in // swiftlint:disable:this prefixed_toplevel_constant
    Calendar.current.shiftedDate(
        componentsFrom: isoDate(string),
        in: .utc
    )
}

let timeZones: [TimeZone] = [ // swiftlint:disable:this prefixed_toplevel_constant
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

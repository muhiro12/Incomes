import Foundation

public struct ItemsPayload: Codable, Sendable {
    public let items: [ItemWire]

    public init(items: [ItemWire]) {
        self.items = items
    }
}

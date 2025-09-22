import Foundation

public struct ItemsRequest: Codable {
    public let baseEpoch: Double
    public let monthOffsets: [Int]

    public init(baseEpoch: Double, monthOffsets: [Int]) {
        self.baseEpoch = baseEpoch
        self.monthOffsets = monthOffsets
    }
}

public struct ItemWire: Codable {
    public let dateEpoch: Double
    public let content: String
    public let income: Double
    public let outgo: Double
    public let category: String

    public init(dateEpoch: Double, content: String, income: Double, outgo: Double, category: String) {
        self.dateEpoch = dateEpoch
        self.content = content
        self.income = income
        self.outgo = outgo
        self.category = category
    }
}

public struct ItemsPayload: Codable {
    public let items: [ItemWire]

    public init(items: [ItemWire]) {
        self.items = items
    }
}

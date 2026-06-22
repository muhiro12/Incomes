import Foundation

public struct ItemWire: Codable, Sendable {
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

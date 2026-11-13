import Foundation

public struct ItemWire: Codable, Sendable {
    public let dateEpoch: Double
    public let content: String
    public let income: Double
    public let outgo: Double
    public let category: String
    public let priority: Int

    public init(
        dateEpoch: Double,
        content: String,
        income: Double,
        outgo: Double,
        category: String,
        priority: Int = 0
    ) {
        self.dateEpoch = dateEpoch
        self.content = content
        self.income = income
        self.outgo = outgo
        self.category = category
        self.priority = priority
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dateEpoch = try values.decode(Double.self, forKey: .dateEpoch)
        content = try values.decode(String.self, forKey: .content)
        income = try values.decode(Double.self, forKey: .income)
        outgo = try values.decode(Double.self, forKey: .outgo)
        category = try values.decode(String.self, forKey: .category)
        // Older phone snapshots omitted priority and were interpreted as zero by the watch.
        priority = try values.decodeIfPresent(Int.self, forKey: .priority) ?? .zero
    }
}

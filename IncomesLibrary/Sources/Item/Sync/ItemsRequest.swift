import Foundation

public struct ItemsRequest: Codable, Sendable {
    public let baseEpoch: Double
    public let monthOffsets: [Int]

    public init(baseEpoch: Double, monthOffsets: [Int]) {
        self.baseEpoch = baseEpoch
        self.monthOffsets = monthOffsets
    }
}

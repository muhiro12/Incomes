import Foundation

public struct ItemsRequest: Codable, Sendable {
    /// Month offsets used by the recent-items watch sync window.
    public static let recentMonthOffsets: [Int] = [-1, 0, 1]

    public let baseEpoch: Double
    public let monthOffsets: [Int]

    public init(baseEpoch: Double, monthOffsets: [Int]) {
        self.baseEpoch = baseEpoch
        self.monthOffsets = monthOffsets
    }
}

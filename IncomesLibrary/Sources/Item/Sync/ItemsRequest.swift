import Foundation

public struct ItemsRequest: Codable, Sendable {
    /// Month offsets used by the recent-items watch sync window.
    public static let recentMonthOffsets: [Int] = [-1, 0, 1]

    public let baseEpoch: Double
    public let monthOffsets: [Int]

    public var baseDate: Date {
        Date(timeIntervalSince1970: baseEpoch)
    }

    public init(baseEpoch: Double, monthOffsets: [Int]) {
        self.baseEpoch = baseEpoch
        self.monthOffsets = monthOffsets
    }

    public static func recent(
        baseDate: Date = .now
    ) -> Self {
        .init(
            baseEpoch: baseDate.timeIntervalSince1970,
            monthOffsets: recentMonthOffsets
        )
    }

    public static func requestData(
        for request: Self
    ) throws -> Data {
        try JSONEncoder().encode(request)
    }

    public static func decodeRequest(
        _ data: Data
    ) throws -> Self {
        try JSONDecoder().decode(
            Self.self,
            from: data
        )
    }
}

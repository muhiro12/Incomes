import Foundation

/// Date bounds and counts for the currently available records.
public struct ItemExportOverview {
    /// Number of all records, including future scheduled items.
    public let totalCount: Int
    /// Earliest displayed day, or nil when no records exist.
    public let firstDate: Date?
    /// Latest displayed day, or nil when no records exist.
    public let lastDate: Date?
}

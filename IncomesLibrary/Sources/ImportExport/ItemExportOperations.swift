import Foundation

/// Read-only summaries and snapshots for exporting Incomes files.
public enum ItemExportOperations {
    /// Uniform type identifier of an Incomes file; the app declares it in Info.plist.
    public static let fileTypeIdentifier = IncomesFileCodec.format
    /// File name extension of an Incomes file.
    public static let fileExtension = "incomes"

    /// Returns the full data extent using the same day convention as Item.localDate.
    public static func overview(
        items: [Item],
        calendar: Calendar = .current
    ) -> ItemExportOverview {
        let dates = items.map(\.utcDate)
        return .init(
            totalCount: items.count,
            firstDate: dates.min().map { date in
                calendar.shiftedDate(componentsFrom: date, in: .utc)
            },
            lastDate: dates.max().map { date in
                calendar.shiftedDate(componentsFrom: date, in: .utc)
            }
        )
    }
}

import Foundation

/// Reads Incomes files, compares them with the store, and applies reviewed imports.
public enum ItemImportOperations {
    /// Largest file accepted for import.
    public static let maximumFileByteCount = IncomesFileCodec.maximumByteCount

    /// Decodes and validates a file without touching the store; safe away from the model actor.
    public static func read(data: Data) throws -> IncomesFileContents {
        try IncomesFileCodec.decode(data)
    }
}

public extension ItemImportOperations {
    /// Returns the file's item count and date extent, shown like `Item.localDate`.
    static func overview(
        contents: IncomesFileContents,
        calendar: Calendar = .current
    ) -> ItemExportOverview {
        let dates = contents.items.map(\.date)
        return .init(
            totalCount: contents.items.count,
            firstDate: dates.min().map { date in
                calendar.shiftedDate(componentsFrom: date, in: .utc)
            },
            lastDate: dates.max().map { date in
                calendar.shiftedDate(componentsFrom: date, in: .utc)
            }
        )
    }
}

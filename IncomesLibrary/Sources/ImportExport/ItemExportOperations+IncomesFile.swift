import Foundation

public extension ItemExportOperations {
    /// Captures every item's file values without changing models, balances, or tags.
    static func fileItems(items: [Item]) -> [IncomesFileItem] {
        IncomesFileItem.sortedByValue(items.map(IncomesFileItem.init(item:)))
    }

    /// Creates an Incomes file for captured items; safe to run away from the model actor.
    static func incomesFileData(
        fileItems: [IncomesFileItem],
        currencyCode: String,
        exportedAt: Date = .now
    ) throws -> Data {
        try IncomesFileCodec.encode(
            items: fileItems,
            currencyCode: currencyCode,
            exportedAt: exportedAt
        )
    }
}

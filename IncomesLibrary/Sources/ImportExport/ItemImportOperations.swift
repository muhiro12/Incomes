import Foundation
import SwiftData

/// Reads Incomes files, compares them with the store, and applies reviewed imports.
public enum ItemImportOperations {
    /// Largest file accepted for import.
    public static let maximumFileByteCount = IncomesFileCodec.maximumByteCount

    /// Decodes and validates a file without touching the store; safe away from the model actor.
    public static func read(data: Data) throws -> IncomesFileContents {
        try IncomesFileCodec.decode(data)
    }

    /// Reads at most the supported size plus one byte, even when the file grows during reading.
    /// The caller owns security-scoped access when the URL comes from a file picker.
    public static func read(at url: URL) throws -> IncomesFileContents {
        let handle = try FileHandle(forReadingFrom: url)
        defer {
            try? handle.close()
        }
        var data = Data()
        while let chunk = try handle.read(upToCount: maximumFileByteCount + 1 - data.count),
              !chunk.isEmpty {
            data.append(chunk)
            guard data.count <= maximumFileByteCount else {
                throw ItemImportError.fileTooLarge
            }
        }
        return try read(data: data)
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

public extension ItemImportOperations {
    /// Owners actually changed by the reviewed policy, excluding records kept as-is.
    static func mutatedLedgerIdentifiers(
        difference: ItemImportDifference,
        policy: ItemImportPolicy
    ) -> Set<LedgerIdentifier> {
        let plan = ItemImportPlan(difference: difference, policy: policy)
        let removedOwners = (difference.changeGroups.flatMap(\.storeItems) + difference.storeOnlyItems)
            .filter { plan.removedItemIDs.contains($0.id) }
            .map(\.item.ledgerIdentifier)
        return Set(plan.insertedItems.map(\.ledgerIdentifier))
            .union(removedOwners)
            .union(plan.ledgerChanges.map(\.id))
    }
}

import Foundation
import SwiftData

public extension WatchSyncOperations {
    /// Saves a complete cache replacement before reporting a successful refresh.
    /// Failure restores the previous cache and leaves unrelated pending edits untouched.
    static func applySnapshotAndSave(
        context: ModelContext,
        items: [ItemWire],
        baseDate: Date = .now,
        monthOffsets: [Int] = ItemsRequest.recentMonthOffsets
    ) throws -> MutationOutcome {
        let mutation: MutationResult<Void> = try ItemMutationSupport.performAndSaveCreatedItems(context: context) {
            .init(
                value: (),
                outcome: try applySnapshot(
                    context: context,
                    items: items,
                    baseDate: baseDate,
                    monthOffsets: monthOffsets
                )
            )
        }
        return mutation.outcome
    }
}

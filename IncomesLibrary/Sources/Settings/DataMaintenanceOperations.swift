import Foundation
import MHPlatformCore
import SwiftData

/// Shared maintenance operations that mutate stored data without any UI concerns.
public enum DataMaintenanceOperations {
    @MainActor
    private final class ResetContextBox: @unchecked Sendable {
        let context: ModelContext

        init(context: ModelContext) {
            self.context = context
        }

        func deleteAllData() throws {
            try DataMaintenanceOperations.deleteAllDataAndSave(context: context)
        }
    }

    /// Deletes all items and tags from the store.
    public static func deleteAllData(context: ModelContext) throws {
        try ItemDeletionOperations.deleteAll(context: context)
        try TagMutationOperations.deleteAll(context: context)
    }

    /// Deletes all items and tags in one save from a clean calling context.
    /// Failures roll back the deletion; unrelated pending edits are refused untouched.
    public static func deleteAllDataAndSave(context: ModelContext) throws {
        try ItemMutationSupport.performAndSave(context: context) {
            try deleteAllData(context: context)
        }
    }

    /// Deletes all stored data through the shared reset orchestration flow.
    @preconcurrency
    @MainActor
    public static func resetAllData(context: ModelContext) async throws {
        let resetContext = ResetContextBox(context: context)

        _ = try await MHDestructiveResetService.runThrowing(
            steps: [
                .init(name: "deleteAllData") {
                    try await MainActor.run {
                        try resetContext.deleteAllData()
                    }
                }
            ]
        )
    }

    /// Deletes tutorial/debug sample data from the store.
    public static func deleteDebugData(context: ModelContext) throws {
        try SampleDataOperations.deleteDebugData(context: context)
    }

    /// Saves sample-data removal before callers report success or refresh other surfaces.
    public static func deleteDebugDataAndSave(context: ModelContext) throws {
        try ItemMutationSupport.performAndSave(context: context) {
            try deleteDebugData(context: context)
        }
    }
}

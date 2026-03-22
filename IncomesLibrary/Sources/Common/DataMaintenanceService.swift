import Foundation
import MHPersistenceMaintenance
import SwiftData

/// Shared maintenance operations that mutate stored data without any UI concerns.
public enum DataMaintenanceService {
    @MainActor
    private final class ResetContextBox: @unchecked Sendable {
        let context: ModelContext

        init(context: ModelContext) {
            self.context = context
        }

        func deleteAllData() throws {
            try DataMaintenanceService.deleteAllData(context: context)
        }
    }

    /// Deletes all items and tags from the store.
    public static func deleteAllData(context: ModelContext) throws {
        try ItemService.deleteAll(context: context)
        try TagService.deleteAll(context: context)
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
        try ItemService.deleteDebugData(context: context)
    }
}

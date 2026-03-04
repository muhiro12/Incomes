import Foundation
import SwiftData

/// Shared maintenance operations that mutate stored data without any UI concerns.
public enum DataMaintenanceService {
    /// Deletes all items and tags from the store.
    public static func deleteAllData(context: ModelContext) throws {
        try ItemService.deleteAll(context: context)
        try TagService.deleteAll(context: context)
    }

    /// Deletes tutorial/debug sample data from the store.
    public static func deleteDebugData(context: ModelContext) throws {
        try ItemService.deleteDebugData(context: context)
    }
}

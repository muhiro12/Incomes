import Foundation
import SwiftData

/// Operations for sample datasets used by previews, tutorials, debug tooling, and smoke checks.
public enum SampleDataOperations {
    /// Preset datasets used when seeding sample data.
    public enum Profile {
        /// Rich sample data used for debug flows.
        case debug
        /// Lightweight tutorial sample data.
        case tutorial
        /// Sample data used by SwiftUI previews.
        case preview
    }

    /// Seeds sample data for various profiles.
    public static func seed(
        context: ModelContext,
        profile: Profile,
        baseDate: Date = .now,
        ignoringDuplicates: Bool = false,
        ifEmptyOnly: Bool = false
    ) throws {
        try ItemSampleDataSeeder.seedSampleData(
            context: context,
            profile: profile.seederProfile,
            baseDate: baseDate,
            ignoringDuplicates: ignoringDuplicates,
            ifEmptyOnly: ifEmptyOnly
        )
    }

    /// Seeds lightweight tutorial/debug items if the store is empty.
    public static func seedTutorialIfNeeded(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        try ItemSampleDataSeeder.seedTutorialDataIfNeeded(
            context: context,
            baseDate: baseDate
        )
    }

    /// Returns whether tutorial/debug data exists.
    public static func hasDebugData(context: ModelContext) throws -> Bool {
        try ItemSampleDataSeeder.hasDebugData(context: context)
    }

    /// Deletes items and tags associated with tutorial/debug data.
    public static func deleteDebugData(context: ModelContext) throws {
        try ItemSampleDataSeeder.deleteDebugData(context: context)
    }

    /// Seeds duplicate category tags for duplicate-tag previews.
    public static func seedDuplicateTagPreviewData(context: ModelContext) throws {
        try ItemSampleDataSeeder.seedDuplicateTagPreviewData(context: context)
    }
}

private extension SampleDataOperations.Profile {
    var seederProfile: ItemSampleDataSeeder.SampleDataProfile {
        switch self {
        case .debug:
            .debug
        case .tutorial:
            .tutorial
        case .preview:
            .preview
        }
    }
}

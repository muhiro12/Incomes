import Foundation
import SwiftData

/// Operations for the named sample-data profiles used by previews, Debug
/// seeding, UI smoke runs, screenshots, and tests.
///
/// Every seeded item carries the debug "Sample Data" tag, so
/// `deleteDebugData(context:)` can remove it again. Seeding writes into the
/// context it receives; callers use an in-memory container unless an explicit
/// Debug or launch-argument action targets the user's store.
public enum SampleDataOperations {
    /// Named sample datasets. Profiles compose the standard ledger where they can.
    public enum Profile: CaseIterable, Sendable {
        /// Three recent items for compact surfaces such as Watch previews.
        case minimal
        /// The canonical two-year ledger for previews, Debug seeding,
        /// UI smoke runs, and screenshots.
        case standard
        /// The standard monthly templates over ten years, for low-priority
        /// performance checks.
        case largeLedger
        /// The standard ledger with two items re-tagged by duplicate tags of
        /// every type, as a sync merge can leave them.
        case duplicateTags
        /// Monthly amounts around ±1,000,000 that exercise compact chart axis labels.
        case largeAmounts
        /// Amounts whose totals cannot be represented exactly.
        case inexactTotals
    }

    /// Seeds `profile` into `context`.
    /// - Parameters:
    ///   - context: The context that receives the sample items.
    ///   - profile: The dataset to seed.
    ///   - baseDate: Anchors dated profiles. Dates use the current calendar
    ///     and time zone.
    ///   - locale: Scales template amounts to the magnitude of the locale's
    ///     currency. Edge-case profiles use fixed amounts.
    ///   - ifEmptyOnly: Skips seeding when the context already has items.
    public static func seed(
        context: ModelContext,
        profile: Profile,
        baseDate: Date = .now,
        locale: Locale = .current,
        ifEmptyOnly: Bool = false
    ) throws {
        try ItemSampleDataSeeder.seed(
            context: context,
            profile: profile,
            baseDate: baseDate,
            locale: locale,
            ifEmptyOnly: ifEmptyOnly
        )
    }

    /// Returns whether sample data exists.
    public static func hasDebugData(context: ModelContext) throws -> Bool {
        try ItemSampleDataSeeder.hasDebugData(context: context)
    }

    /// Deletes the items and tags created by sample-data profiles.
    public static func deleteDebugData(context: ModelContext) throws {
        try ItemSampleDataSeeder.deleteDebugData(context: context)
    }
}

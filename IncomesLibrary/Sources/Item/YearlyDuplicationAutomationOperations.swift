import SwiftData

/// Automation operations for yearly item duplication App Intent flows.
public enum YearlyDuplicationAutomationOperations {
    /// Result summary for applying yearly duplication from an automation surface.
    public struct ApplyResult: Sendable {
        /// Number of items created.
        public let createdCount: Int
        /// Number of planned groups.
        public let groupCount: Int
        /// Number of planned items.
        public let itemCount: Int

        /// Creates an automation apply result.
        public init(
            createdCount: Int,
            groupCount: Int,
            itemCount: Int
        ) {
            self.createdCount = createdCount
            self.groupCount = groupCount
            self.itemCount = itemCount
        }
    }

    /// Result summary for previewing yearly duplication from an automation surface.
    public struct PreviewResult: Sendable {
        /// Human-readable plan summary.
        public let summaryText: String
        /// Number of planned groups.
        public let groupCount: Int
        /// Number of planned items.
        public let itemCount: Int
        /// Number of skipped duplicates.
        public let skippedCount: Int

        /// Creates an automation preview result.
        public init(
            summaryText: String,
            groupCount: Int,
            itemCount: Int,
            skippedCount: Int
        ) {
            self.summaryText = summaryText
            self.groupCount = groupCount
            self.itemCount = itemCount
            self.skippedCount = skippedCount
        }
    }

    /// Returns yearly duplication options from automation parameters.
    public static func options(
        includeSingleItems: Bool,
        minimumRepeatItemCount: Int,
        skipExistingItems: Bool
    ) -> YearlyItemDuplicationOptions {
        .init(
            includeSingleItems: includeSingleItems,
            minimumRepeatItemCount: minimumRepeatItemCount,
            skipExistingItems: skipExistingItems
        )
    }

    /// Applies yearly duplication for the selected source and target years.
    public static func apply(
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int,
        options: YearlyItemDuplicationOptions
    ) throws -> ApplyResult {
        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: sourceYear,
            targetYear: targetYear,
            options: options
        )
        let result = try YearlyItemDuplicationApplyOperations.apply(
            plan: plan,
            context: context
        )
        return .init(
            createdCount: result.createdCount,
            groupCount: plan.groups.count,
            itemCount: plan.entries.count
        )
    }

    /// Previews yearly duplication for the selected source and target years.
    public static func preview(
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int,
        options: YearlyItemDuplicationOptions
    ) throws -> PreviewResult {
        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: sourceYear,
            targetYear: targetYear,
            options: options
        )
        return .init(
            summaryText: YearlyDuplicationPresentationOperations.summaryText(for: plan),
            groupCount: plan.groups.count,
            itemCount: plan.entries.count,
            skippedCount: plan.skippedDuplicateCount
        )
    }

    /// Returns available source years for yearly duplication.
    public static func sourceYears(context: ModelContext) throws -> [Int] {
        try YearlyItemDuplicationSelectionOperations.availableSourceYears(
            context: context
        )
    }

    /// Returns selectable target years.
    public static func targetYears(
        currentYear: Int?,
        range: Int
    ) -> [Int] {
        YearlyItemDuplicationSelectionOperations.targetYears(
            currentYear: currentYear ?? YearlyItemDuplicationSelectionOperations.currentYear(),
            range: range
        )
    }

    /// Returns a human-readable yearly duplication suggestion.
    public static func suggestionText(
        context: ModelContext,
        minimumGroupCount: Int,
        options: YearlyItemDuplicationOptions
    ) throws -> String? {
        let targetYears = YearlyItemDuplicationSelectionOperations.targetYears()
        let suggestion = try YearlyItemDuplicationSelectionOperations.suggestion(
            context: context,
            targetYears: targetYears,
            minimumGroupCount: minimumGroupCount,
            options: options
        )
        guard let suggestion else {
            return nil
        }
        return YearlyDuplicationPresentationOperations.suggestionText(for: suggestion)
    }
}

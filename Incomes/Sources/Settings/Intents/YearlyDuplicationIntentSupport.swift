import SwiftData

enum YearlyDuplicationIntentSupport {
    struct ApplyResult {
        let createdCount: Int
        let groupCount: Int
        let itemCount: Int
    }

    struct PreviewResult {
        let summaryText: String
        let groupCount: Int
        let itemCount: Int
        let skippedCount: Int
    }

    nonisolated static func options(
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

    nonisolated static func requestMetadata(
        sourceYear: Int,
        targetYear: Int,
        includeSingleItems: Bool,
        minimumRepeatItemCount: Int,
        skipExistingItems: Bool
    ) -> [String: String] {
        IncomesLogging.metadata(
            ("source_year", String(sourceYear)),
            ("target_year", String(targetYear)),
            ("include_single_items", IncomesLogging.bool(includeSingleItems)),
            ("minimum_repeat_item_count", String(minimumRepeatItemCount)),
            ("skip_existing_items", IncomesLogging.bool(skipExistingItems))
        )
    }

    static func apply(
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int,
        options: YearlyItemDuplicationOptions
    ) throws -> ApplyResult {
        let plan = try plan(
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

    static func preview(
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int,
        options: YearlyItemDuplicationOptions
    ) throws -> PreviewResult {
        let plan = try plan(
            context: context,
            sourceYear: sourceYear,
            targetYear: targetYear,
            options: options
        )
        return .init(
            summaryText: YearlyItemDuplicationPresentationBuilder.summaryText(for: plan),
            groupCount: plan.groups.count,
            itemCount: plan.entries.count,
            skippedCount: plan.skippedDuplicateCount
        )
    }

    static func sourceYears(context: ModelContext) throws -> [Int] {
        try YearlyItemDuplicationSelectionOperations.availableSourceYears(
            context: context
        )
    }

    nonisolated static func targetYears(
        currentYear: Int?,
        range: Int
    ) -> [Int] {
        YearlyItemDuplicationSelectionOperations.targetYears(
            currentYear: currentYear ?? YearlyItemDuplicationSelectionOperations.currentYear(),
            range: range
        )
    }

    static func suggestionText(
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
        return YearlyItemDuplicationPresentationBuilder.suggestionText(for: suggestion)
    }

    private static func plan(
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int,
        options: YearlyItemDuplicationOptions
    ) throws -> YearlyItemDuplicationPlan {
        try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: sourceYear,
            targetYear: targetYear,
            options: options
        )
    }
}

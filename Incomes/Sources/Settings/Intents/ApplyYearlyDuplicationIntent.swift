import AppIntents
import SwiftData

struct ApplyYearlyDuplicationIntent: AppIntent {
    @Parameter(title: "Source Year")
    private var sourceYear: Int
    @Parameter(title: "Target Year")
    private var targetYear: Int
    @Parameter(title: "Include Single Items", default: false)
    private var includeSingleItems: Bool
    @Parameter(title: "Minimum Repeat Item Count", default: 3, inclusiveRange: (1, 60))
    private var minimumRepeatItemCount: Int
    @Parameter(title: "Skip Existing Items", default: true)
    private var skipExistingItems: Bool

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Apply Yearly Duplication", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        let plan = try YearlyItemDuplicator.plan(
            context: modelContainer.mainContext,
            sourceYear: sourceYear,
            targetYear: targetYear,
            options: duplicationOptions
        )
        let result = try YearlyItemDuplicator.apply(
            plan: plan,
            context: modelContainer.mainContext
        )
        return .result(value: result.createdCount)
    }
}

private extension ApplyYearlyDuplicationIntent {
    var duplicationOptions: YearlyItemDuplicationOptions {
        .init(
            includeSingleItems: includeSingleItems,
            minimumRepeatItemCount: minimumRepeatItemCount,
            skipExistingItems: skipExistingItems
        )
    }
}

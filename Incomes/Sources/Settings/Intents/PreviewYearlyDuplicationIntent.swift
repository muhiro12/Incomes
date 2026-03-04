import AppIntents
import SwiftData

struct PreviewYearlyDuplicationIntent: AppIntent {
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

    static let title: LocalizedStringResource = .init("Preview Yearly Duplication", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some ReturnsValue<String> {
        let plan = try YearlyItemDuplicator.plan(
            context: modelContainer.mainContext,
            sourceYear: sourceYear,
            targetYear: targetYear,
            options: duplicationOptions
        )
        let summary = "\(plan.groups.count) groups / \(plan.entries.count) items / \(plan.skippedDuplicateCount) skipped"
        return .result(value: summary)
    }
}

private extension PreviewYearlyDuplicationIntent {
    var duplicationOptions: YearlyItemDuplicationOptions {
        .init(
            includeSingleItems: includeSingleItems,
            minimumRepeatItemCount: minimumRepeatItemCount,
            skipExistingItems: skipExistingItems
        )
    }
}

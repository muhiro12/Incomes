import AppIntents
import SwiftData

struct PreviewYearlyDuplicationIntent: AppIntent {
    @Parameter(title: "Source Year")
    private var sourceYear: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Target Year")
    private var targetYear: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Include Single Items", default: false)
    private var includeSingleItems: Bool // swiftlint:disable:this type_contents_order
    @Parameter(title: "Minimum Repeat Item Count", default: 3, inclusiveRange: (1, 60)) // swiftlint:disable:this line_length no_magic_numbers
    private var minimumRepeatItemCount: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Skip Existing Items", default: true)
    private var skipExistingItems: Bool // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

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
        let summary = "\(plan.groups.count) groups / \(plan.entries.count) items / \(plan.skippedDuplicateCount) skipped" // swiftlint:disable:this line_length
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

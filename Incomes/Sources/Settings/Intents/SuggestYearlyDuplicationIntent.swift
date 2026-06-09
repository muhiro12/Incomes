import AppIntents
import SwiftData

struct SuggestYearlyDuplicationIntent: AppIntent {
    @Parameter(title: "Minimum Group Count", default: 3, inclusiveRange: (1, 60)) // swiftlint:disable:this line_length no_magic_numbers
    private var minimumGroupCount: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Include Single Items", default: false)
    private var includeSingleItems: Bool // swiftlint:disable:this type_contents_order
    @Parameter(title: "Minimum Repeat Item Count", default: 3, inclusiveRange: (1, 60)) // swiftlint:disable:this line_length no_magic_numbers
    private var minimumRepeatItemCount: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Skip Existing Items", default: true)
    private var skipExistingItems: Bool // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Suggest Yearly Duplication", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try YearlyDuplicationIntentSupport.suggestionText(
                context: modelContainer.mainContext,
                minimumGroupCount: minimumGroupCount,
                options: duplicationOptions
            )
        )
    }
}

private extension SuggestYearlyDuplicationIntent {
    var duplicationOptions: YearlyItemDuplicationOptions {
        YearlyDuplicationIntentSupport.options(
            includeSingleItems: includeSingleItems,
            minimumRepeatItemCount: minimumRepeatItemCount,
            skipExistingItems: skipExistingItems
        )
    }
}

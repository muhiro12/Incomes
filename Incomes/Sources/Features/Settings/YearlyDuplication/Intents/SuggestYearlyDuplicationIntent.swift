import AppIntents
import SwiftData

struct SuggestYearlyDuplicationIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Suggest Yearly Duplication", table: "AppIntents")

    // swiftlint:disable no_magic_numbers
    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$minimumGroupCount
            \.$includeSingleItems
            \.$minimumRepeatItemCount
            \.$skipExistingItems
            \.$ledger
        }
    }

    @Parameter(title: "Minimum Group Count", default: 3, inclusiveRange: (1, 60))
    private var minimumGroupCount: Int
    @Parameter(title: "Include Single Items", default: false)
    private var includeSingleItems: Bool
    @Parameter(title: "Minimum Repeat Item Count", default: 3, inclusiveRange: (1, 60))
    private var minimumRepeatItemCount: Int
    // swiftlint:enable no_magic_numbers
    @Parameter(title: "Skip Existing Items", default: true)
    private var skipExistingItems: Bool

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try YearlyDuplicationAutomationOperations.suggestionText(
                context: modelContainer.mainContext,
                minimumGroupCount: minimumGroupCount,
                options: duplicationOptions,
                ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
            )
        )
    }
}

private extension SuggestYearlyDuplicationIntent {
    var duplicationOptions: YearlyItemDuplicationOptions {
        YearlyDuplicationAutomationOperations.options(
            includeSingleItems: includeSingleItems,
            minimumRepeatItemCount: minimumRepeatItemCount,
            skipExistingItems: skipExistingItems
        )
    }
}

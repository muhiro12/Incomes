import AppIntents
import MHPlatform
import SwiftData

struct ImportDataIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Import Incomes Data", table: "AppIntents")
    // Public conflict review and locked-device behavior need their own product decision.
    static let isDiscoverable = false

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$file
            \.$policy
            \.$recalculatesBalances
            \.$adoptsFileCurrency
        }
    }

    @Parameter(title: "File", supportedContentTypes: [.json])
    private var file: IntentFile
    @Parameter(title: "Import Policy", default: .merge)
    private var policy: ImportDataPolicyIntentValue
    @Parameter(title: "Recalculate imported balances", default: false)
    private var recalculatesBalances: Bool
    @Parameter(title: "Use Currency from File", default: false)
    private var adoptsFileCurrency: Bool

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var notificationService: NotificationService
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor
    func perform() async throws -> some ReturnsValue<String> {
        let contents = try await DataImportIntentSupport.contents(of: file)
        let context = modelContainer.mainContext
        let preferences = MHPreferenceStore()
        let currencyCode = preferences.string(for: \.currencyCode) ?? ""
        let difference = try IncomesIntentError.perform {
            try ItemImportOperations.difference(contents: contents, context: context)
        }
        let summary = try confirmationSummary(contents: contents, difference: difference)
        try await requestConfirmation(dialog: .init("\(summary)"))
        try Task.checkCancellation()
        let logger = IncomesIntentLoggingSupport.appIntentLogger(logging: logging, source: #fileID)
        do {
            let result = try await DataImportCoordinator.apply(
                .init(
                    contents: contents,
                    difference: difference,
                    policy: policy.policy,
                    balancePolicy: recalculatesBalances ? .recalculate : .preserveSavedBalances,
                    reviewedCurrencyCode: currencyCode
                ),
                context: context,
                didSave: {
                    if adoptsFileCurrency, let code = contents.currencyCode {
                        preferences.set(code, for: \.currencyCode)
                    }
                },
                refreshNotificationSchedule: {
                    await IncomesMutationWorkflow.refreshNotificationSchedule(notificationService: notificationService)
                },
                logger: logger
            )
            return .result(value: String(localized: "Imported \(result.addedCount) items."))
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw IncomesIntentError(error)
        }
    }
}

private extension ImportDataIntent {
    @MainActor
    func confirmationSummary(contents: IncomesFileContents, difference: ItemImportDifference) throws -> String {
        try IncomesIntentError.perform {
            let identifiers = ItemImportOperations.mutatedLedgerIdentifiers(
                difference: difference, policy: policy.policy
            )
            try LedgerMutationAccess.requireEditing(identifiers)
            let review = try ItemImportOperations.balanceReview(difference: difference, policy: policy.policy)
            if recalculatesBalances, !review.canRecalculate {
                throw ItemAmountError.balanceOutOfRange
            }
            var messages = [DataImportIntentSupport.summary(
                result: ItemImportOperations.result(difference: difference, policy: policy.policy),
                balanceReview: review
            )]
            if recalculatesBalances {
                messages.append(String(localized: """
                    Recalculation starts at the earliest imported change in each ledger.
                    """))
            } else {
                messages.append(String(localized: "Saved balances are kept unless you choose recalculation."))
            }
            if adoptsFileCurrency, let code = contents.currencyCode {
                messages.append(String(localized: "Use currency from file: \(code)."))
            }
            return messages.joined(separator: "\n")
        }
    }
}

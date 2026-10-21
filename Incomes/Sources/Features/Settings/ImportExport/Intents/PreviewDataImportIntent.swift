import AppIntents
import SwiftData

struct PreviewDataImportIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Preview Data Import", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$file
            \.$policy
        }
    }

    @Parameter(title: "File", supportedContentTypes: [.json])
    private var file: IntentFile
    @Parameter(title: "Import Policy", default: .merge)
    private var policy: ImportDataPolicyIntentValue

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() async throws -> some ReturnsValue<String> {
        let contents = try await DataImportIntentSupport.contents(of: file)
        let summary = try IncomesIntentError.perform {
            let difference = try ItemImportOperations.difference(
                contents: contents, context: modelContainer.mainContext
            )
            return try DataImportIntentSupport.summary(
                result: ItemImportOperations.result(difference: difference, policy: policy.policy),
                balanceReview: ItemImportOperations.balanceReview(difference: difference, policy: policy.policy)
            )
        }
        return .result(value: summary)
    }
}

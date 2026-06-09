import AppIntents
import Foundation
import MHPlatform

@available(iOS 26.0, *)
struct InferItemFormIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Infer Item Form", table: "AppIntents")
    static let isDiscoverable = false

    @Parameter(title: "Text")
    private var text: String
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor
    func perform() async throws -> some ReturnsValue<ItemFormInference> {
        let result = try await ItemInferenceService.inferForm(
            text: text,
            locale: .current,
            currentDate: Date(),
            logger: intentLogger
        )
        return .result(value: result)
    }
}

@available(iOS 26.0, *)
private extension InferItemFormIntent {
    @MainActor var intentLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.appIntent,
            source: #fileID
        )
    }
}

import AppIntents
import FoundationModels

@available(iOS 26.0, *)
struct InferItemFormIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Infer Item Form", table: "AppIntents")

    @Parameter(title: "Text")
    private var text: String

    @MainActor
    func perform() async throws -> some ReturnsValue<ItemFormInference> {
        let result = try await ItemService.inferForm(text: text)
        return .result(value: result)
    }
}

import AppIntents
import FoundationModels

@available(iOS 26.0, *)
@MainActor
struct InferItemFormIntent: AppIntent, IntentPerformer {
    nonisolated static let title: LocalizedStringResource = .init("Infer Item Form", table: "AppIntents")

    @Parameter(title: "Text")
    private var text: String

    typealias Input = String
    typealias Output = ItemFormInference

    static func perform(_ input: Input) async throws -> Output {
        return try await ItemService.inferForm(text: input)
    }

    func perform() async throws -> some ReturnsValue<ItemFormInference> {
        let result = try await Self.perform(text)
        return .result(value: result)
    }
}

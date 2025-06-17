import AppIntents
import FoundationModels

@available(iOS 26.0, *)
struct InferItemFormIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Infer Item Form", table: "AppIntents")

    @Parameter(title: "Text")
    private var text: String

    typealias Input = (text: String)
    typealias Output = ItemFormInference

    static func perform(_ input: Input) async throws -> Output {
        let session = LanguageModelSession()
        let prompt = """
            Extract date(yyyyMMdd), content, income, outgo and category from the following text.
            Respond only with the values.
            Text: \(input.text)
            """
        let response = try await session.respond(to: prompt, generating: ItemFormInference.self)
        return response.content
    }

    func perform() async throws -> some ReturnsValue<ItemFormInference> {
        let result = try await Self.perform((text: text))
        return .result(value: result)
    }
}

import AppIntents
import FoundationModels

@available(iOS 26.0, *)
struct InferItemFormIntent: AppIntent, IntentPerformer {
    nonisolated static let title: LocalizedStringResource = .init("Infer Item Form", table: "AppIntents")

    @Parameter(title: "Text")
    private var text: String

    typealias Input = String
    typealias Output = ItemFormInference

    static func perform(_ input: Input) async throws -> Output {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let today = formatter.string(from: Date())

        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let session = LanguageModelSession(
            instructions: """
                You are a professional financial advisor for a household accounting and budgeting app. Carefully extract and output the necessary fields from user input as an expert accountant.
                Always provide reliable and precise results.
                """
        )
        let prompt = """
            Today's date is: \(today)
            You are a professional financial advisor for a household accounting and budgeting app. Carefully extract and output the following fields from the user input:
            - date (yyyyMMdd) (If the date in the text is relative, such as 'last month' or 'next month', convert it to the correct date)
            - content (description)
            - income
            - outgo
            - category

            REQUIREMENT:
            - Respond ONLY with the values in the language: \(languageCode).
            - Never reply in English unless the device language is English.
            - All field values must be in the device's language, matching the user's input language.
            - If the language is Japanese, return all labels and values in Japanese, and treat relative time expressions (like '来月', '先月') accurately.
            - Output only the result values, no explanation, format, or extra words.

            Text: \(input)
            """
        let response = try await session.respond(
            to: prompt,
            generating: ItemFormInference.self
        )
        return response.content
    }

    func perform() async throws -> some ReturnsValue<ItemFormInference> {
        let result = try await Self.perform(text)
        return .result(value: result)
    }
}

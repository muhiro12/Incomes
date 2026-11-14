import Foundation
import FoundationModels

@main
private enum ItemInferenceProbe {
    private struct Input: Decodable {
        let text: String
        let referenceDate: String
        let locale: String
    }

    private struct Output: Encodable {
        let date: String
        let dateExpression: String
        let content: String
        let hasUnspecifiedAmount: Bool
        let income: String
        let outgo: String
        let category: String
        let generatedJSON: String
        let normalizationError: String?
        let instructions: String
        let prompt: String
    }

    private enum Failure: Error {
        case invalidReferenceDate
        case modelUnavailable
        case unsupportedLocale
    }

    private static let errorExitCode: Int32 = 2
    private static let referenceDateLength = 8

    static func main() async {
        do {
            let input = try JSONDecoder().decode(
                Input.self,
                from: FileHandle.standardInput.readDataToEndOfFile()
            )
            let output = try await generate(input)
            let data = try JSONEncoder().encode(output)
            FileHandle.standardOutput.write(data)
        } catch {
            let data = Data("\(error)\n".utf8)
            FileHandle.standardError.write(data)
            exit(errorExitCode)
        }
    }

    private static func generate(_ input: Input) async throws -> Output {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            throw Failure.modelUnavailable
        }
        let locale = Locale(identifier: input.locale)
        guard model.supportsLocale(locale) else {
            throw Failure.unsupportedLocale
        }
        let instructions = ItemFormInferencePromptBuilder.instructions()
        let prompt = try ItemFormInferencePromptBuilder.prompt(
            text: input.text,
            currentDate: referenceDate(input.referenceDate),
            locale: locale
        )
        let session = LanguageModelSession(model: model) {
            instructions
        }
        let response = try await session.respond(
            generating: ItemFormInferenceGeneratedFields.self,
            options: .init(samplingMode: .greedy)
        ) {
            prompt
        }
        return try output(generated: response.content, input: input, instructions: instructions, prompt: prompt)
    }

    private static func output(
        generated: ItemFormInferenceGeneratedFields, input: Input, instructions: String, prompt: String
    ) -> Output {
        let result: ItemFormInferenceResult?
        let normalizationError: String?
        do {
            result = try ItemFormInferenceResult(
                generated: generated,
                sourceText: input.text,
                referenceDate: referenceDate(input.referenceDate),
                locale: .init(identifier: input.locale)
            )
            normalizationError = nil
        } catch {
            result = nil
            normalizationError = String(describing: error)
        }
        return .init(
            date: result?.date ?? "",
            dateExpression: generated.dateExpression,
            content: generated.content,
            hasUnspecifiedAmount: result?.hasUnspecifiedAmount ?? true,
            income: result?.income.description ?? "",
            outgo: result?.outgo.description ?? "",
            category: generated.category,
            generatedJSON: generated.generatedContent.jsonString,
            normalizationError: normalizationError,
            instructions: instructions,
            prompt: prompt
        )
    }

    private static func referenceDate(_ text: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.calendar = .init(identifier: .gregorian)
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyyMMdd"
        formatter.isLenient = false
        guard text.utf8.count == referenceDateLength,
              let date = formatter.date(from: text),
              formatter.string(from: date) == text else {
            throw Failure.invalidReferenceDate
        }
        return date
    }
}

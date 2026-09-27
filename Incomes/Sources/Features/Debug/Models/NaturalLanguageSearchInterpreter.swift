import Foundation
import FoundationModels
import MHPlatform

@available(iOS 26.0, *)
enum NaturalLanguageSearchInterpreter {
    private static let maximumResponseTokens = 200

    /// Returns why interpretation cannot start, or `nil` when the model is ready.
    static func unavailableReason(locale: Locale) -> NaturalLanguageSearchError? {
        do {
            _ = try model(for: locale)
            return nil
        } catch let error as NaturalLanguageSearchError {
            return error
        } catch {
            return .unavailableModel
        }
    }

    /// Extracts and validates search conditions for one submission.
    ///
    /// Only the request text and the captured month go to the model; saved
    /// items are never sent. Requests and responses are not logged.
    static func conditions(
        for submission: NaturalLanguageSearchState.Submission,
        calendar: Calendar,
        locale: Locale
    ) async throws -> ItemSearchConditions {
        do {
            return try await validatedConditions(
                for: submission,
                calendar: calendar,
                locale: locale
            )
        } catch {
            if error is CancellationError {
                throw error
            }
            throw searchError(from: error)
        }
    }
}

@available(iOS 26.0, *)
private extension NaturalLanguageSearchInterpreter {
    static func model(for locale: Locale) throws -> SystemLanguageModel {
        try FoundationModelAvailabilitySupport.defaultModel(
            for: locale,
            unavailableModelError: NaturalLanguageSearchError.unavailableModel,
            unsupportedLocaleError: NaturalLanguageSearchError.unsupportedLocale
        )
    }

    static func validatedConditions(
        for submission: NaturalLanguageSearchState.Submission,
        calendar: Calendar,
        locale: Locale
    ) async throws -> ItemSearchConditions {
        let model = try model(for: locale)
        let instructions = NaturalLanguageSearchOperations.instructions()
        let session = LanguageModelSession(model: model) {
            instructions
        }
        let prompt = NaturalLanguageSearchOperations.prompt(
            request: submission.request,
            currentDate: submission.currentDate,
            calendar: calendar
        )
        let options = FoundationModelToolchainSupport.greedyGenerationOptions(
            maximumResponseTokens: maximumResponseTokens
        )
        let response = try await session.respond(
            generating: NaturalLanguageSearchInference.self,
            options: options
        ) {
            prompt
        }
        try Task.checkCancellation()
        return try NaturalLanguageSearchOperations.conditions(
            from: response.content.extraction,
            request: submission.request,
            currentDate: submission.currentDate,
            calendar: calendar
        )
    }

    static func searchError(from error: Error) -> NaturalLanguageSearchError {
        if let error = error as? NaturalLanguageSearchError {
            return error
        }
        if FoundationModelAvailabilitySupport.isUnsupportedLocaleError(error) {
            return .unsupportedLocale
        }
        return .generationFailed
    }
}

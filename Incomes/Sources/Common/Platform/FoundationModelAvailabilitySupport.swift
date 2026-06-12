import Foundation
import FoundationModels

@available(iOS 26.0, *)
enum FoundationModelAvailabilitySupport {
    static func defaultModel<Failure: Error>(
        for locale: Locale,
        unavailableModelError: @autoclosure () -> Failure,
        unsupportedLocaleError: @autoclosure () -> Failure
    ) throws -> SystemLanguageModel {
        try availableModel(
            SystemLanguageModel.default,
            locale: locale,
            unavailableModelError: unavailableModelError(),
            unsupportedLocaleError: unsupportedLocaleError()
        )
    }

    static func generalModel<Failure: Error>(
        for locale: Locale,
        unavailableModelError: @autoclosure () -> Failure,
        unsupportedLocaleError: @autoclosure () -> Failure
    ) throws -> SystemLanguageModel {
        try availableModel(
            SystemLanguageModel(useCase: .general),
            locale: locale,
            unavailableModelError: unavailableModelError(),
            unsupportedLocaleError: unsupportedLocaleError()
        )
    }

    static func isUnsupportedLocaleError(
        _ error: LanguageModelSession.GenerationError
    ) -> Bool {
        switch error {
        case .unsupportedLanguageOrLocale:
            return true
        default:
            return false
        }
    }

    private static func availableModel<Failure: Error>(
        _ model: SystemLanguageModel,
        locale: Locale,
        unavailableModelError: @autoclosure () -> Failure,
        unsupportedLocaleError: @autoclosure () -> Failure
    ) throws -> SystemLanguageModel {
        switch model.availability {
        case .available:
            break
        case .unavailable:
            throw unavailableModelError()
        }

        guard model.supportsLocale(locale) else {
            throw unsupportedLocaleError()
        }

        return model
    }
}

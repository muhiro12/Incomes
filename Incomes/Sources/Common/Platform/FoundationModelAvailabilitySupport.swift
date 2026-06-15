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

    static func isUnsupportedLocaleError(_ error: Error) -> Bool {
        if #unavailable(iOS 27.0) {
            if let error = error as? LanguageModelSession.GenerationError {
                switch error {
                case .unsupportedLanguageOrLocale:
                    return true
                default:
                    break
                }
            }
        }

        #if compiler(>=6.4)
        if #available(iOS 27.0, *),
           let error = error as? LanguageModelError {
            switch error {
            case .unsupportedLanguageOrLocale:
                return true
            default:
                break
            }
        }
        #endif

        return false
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

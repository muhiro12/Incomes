import FoundationModels

@available(iOS 26.0, *)
enum FoundationModelToolchainSupport {
    // Keep SDK 27 source spelling isolated so feature code remains buildable with Xcode 26.
    static func isUnsupportedLocaleError(_ error: Error) -> Bool {
        #if compiler(>=6.4)
        if #available(iOS 27.0, *),
           let error = error as? LanguageModelError {
            switch error {
            case .unsupportedLanguageOrLocale:
                return true
            default:
                return false
            }
        }
        #endif

        if #unavailable(iOS 27.0) {
            if let error = error as? LanguageModelSession.GenerationError {
                switch error {
                case .unsupportedLanguageOrLocale:
                    return true
                default:
                    return false
                }
            }
        }

        return false
    }

    static func greedyGenerationOptions(maximumResponseTokens: Int) -> GenerationOptions {
        #if compiler(>=6.4)
        GenerationOptions(
            samplingMode: .greedy,
            maximumResponseTokens: maximumResponseTokens
        )
        #else
        GenerationOptions(
            sampling: .greedy,
            maximumResponseTokens: maximumResponseTokens
        )
        #endif
    }
}

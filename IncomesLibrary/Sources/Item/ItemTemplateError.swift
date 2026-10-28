import Foundation

/// Recoverable template failures; reading a template never changes stored data.
public enum ItemTemplateError: LocalizedError, Equatable {
    /// Input exceeds the documented byte or line limit.
    case tooLarge
    /// The identifier, version declaration, or bullet structure is malformed.
    case invalidStructure
    /// No reader exists for this template version.
    case unsupportedVersion
    /// A required section is absent.
    case missingField(String)
    /// A section appears more than once.
    case duplicateField(String)
    /// A section is not part of the supported template.
    case unknownField(String)
    /// A field is blank, ambiguous, or outside its supported representation.
    case invalidField(String)
    /// An explicit currency setting is required for exchange.
    case currencyRequired
    /// The template currency differs from the app's setting.
    case currencyMismatch

    public var errorDescription: String? {
        switch self {
        case .tooLarge:
            String(
                localized: "The template is too large. Use one item with at most 16 KiB and 512 lines.",
                bundle: .module
            )
        case .invalidStructure:
            String(
                localized: "Use the Incomes template with its version, headings, and one bullet per section.",
                bundle: .module
            )
        case .unsupportedVersion:
            String(localized: "This template version is not supported.", bundle: .module)
        case .missingField(let field):
            String(localized: "The template is missing the \(field) section.", bundle: .module)
        case .duplicateField(let field):
            String(localized: "The template contains more than one \(field) section.", bundle: .module)
        case .unknownField(let field):
            String(localized: "The template contains an unsupported section: \(field).", bundle: .module)
        case .invalidField(let field):
            String(localized: "Check the \(field) value against the template instructions.", bundle: .module)
        case .currencyRequired:
            String(localized: "Choose a currency in Settings before exchanging templates.", bundle: .module)
        case .currencyMismatch:
            String(
                localized: "The template currency must match the currency in Settings. No amounts were converted.",
                bundle: .module
            )
        }
    }
}

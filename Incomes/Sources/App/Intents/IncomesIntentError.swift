import AppIntents
import Foundation

/// Converts existing localized domain failures into messages delivered by Shortcuts.
struct IncomesIntentError: Error, CustomLocalizedStringResourceConvertible {
    private let message: String

    var localizedStringResource: LocalizedStringResource {
        .init("\(message)")
    }

    init(_ error: any Error) {
        message = ErrorMessageOperations.message(from: error)
    }

    @MainActor
    static func perform<Value>(_ operation: () throws -> Value) throws -> Value {
        do {
            return try operation()
        } catch {
            throw Self(error)
        }
    }
}

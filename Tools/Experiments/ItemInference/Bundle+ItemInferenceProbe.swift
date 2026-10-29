import Foundation

// Standalone compilation replaces only SwiftPM's generated resource-bundle accessor.
extension Bundle {
    static var module: Bundle {
        guard let path = ProcessInfo.processInfo.environment["INCOMES_MODEL_EVALUATION_RESOURCES"],
              let bundle = Bundle(path: path) else {
            preconditionFailure("Missing evaluation resource bundle")
        }
        return bundle
    }
}

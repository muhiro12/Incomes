import Foundation // swiftlint:disable:this file_name

public extension String {
    /// Documented for SwiftLint compliance.
    var isEmptyOrInt: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return true
        }
        return Int(trimmed) != nil
    }

    /// Documented for SwiftLint compliance.
    var intValue: Int {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(trimmed) ?? .zero
    }
}

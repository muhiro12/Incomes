import Foundation // swiftlint:disable:this file_name

public extension String {
    /// True when the string is blank or can be parsed as an integer.
    var isEmptyOrInt: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return true
        }
        return Int(trimmed) != nil
    }

    /// Integer value parsed from the string, or `0` when parsing fails.
    var intValue: Int {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(trimmed) ?? .zero
    }
}

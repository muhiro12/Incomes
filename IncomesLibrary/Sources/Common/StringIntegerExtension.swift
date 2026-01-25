import Foundation

public extension String {
    var isEmptyOrInt: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return true
        }
        return Int(trimmed) != nil
    }

    var intValue: Int {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(trimmed) ?? .zero
    }
}

import Foundation

public enum VersionComparator {
    public static func isUpdateRequired(current: String, required: String) -> Bool {
        current.compare(required, options: .numeric) == .orderedAscending
    }
}

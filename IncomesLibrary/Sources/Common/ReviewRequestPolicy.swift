import Foundation

public enum ReviewRequestPolicy {
    public static func shouldRequestReview(
        randomValue: Int,
        maxExclusive: Int
    ) -> Bool {
        guard maxExclusive > 0 else {
            return false
        }
        return randomValue == 0
    }
}

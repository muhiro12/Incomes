import Foundation

/// Distinguishes generated prose from the calculated fallback without persisting either.
struct MonthlySummaryResult: Sendable {
    let text: String
    let isModelGenerated: Bool
}

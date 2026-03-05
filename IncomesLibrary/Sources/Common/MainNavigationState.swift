import Foundation
import SwiftData

/// Documented for SwiftLint compliance.
public struct MainNavigationState {
    /// Documented for SwiftLint compliance.
    public let yearTag: Tag?
    /// Documented for SwiftLint compliance.
    public let yearMonthTag: Tag?

    /// Documented for SwiftLint compliance.
    public init(
        yearTag: Tag?,
        yearMonthTag: Tag?
    ) {
        self.yearTag = yearTag
        self.yearMonthTag = yearMonthTag
    }
}

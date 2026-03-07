import Foundation
import SwiftData

/// Default year and month selections for the main navigation UI.
public struct MainNavigationState {
    /// Selected year tag, if available.
    public let yearTag: Tag?
    /// Selected year-month tag, if available.
    public let yearMonthTag: Tag?

    /// Creates a navigation state from the resolved year and month tags.
    public init(
        yearTag: Tag?,
        yearMonthTag: Tag?
    ) {
        self.yearTag = yearTag
        self.yearMonthTag = yearMonthTag
    }
}

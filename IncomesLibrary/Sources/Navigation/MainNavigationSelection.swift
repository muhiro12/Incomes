import SwiftData

/// The year and its selected child in the main navigation hierarchy.
public struct MainNavigationSelection {
    /// The year shown in the month list.
    public private(set) var yearTagID: Tag.ID?
    /// The month or annual summary selected within that year.
    public var selectedTag: Tag?

    /// Creates a selection from a resolved route or an empty sidebar.
    public init(yearTagID: Tag.ID? = nil, selectedTag: Tag? = nil) {
        self.yearTagID = yearTagID
        self.selectedTag = selectedTag
    }

    /// Changes the year and clears its old child. Reselecting the year preserves that child.
    /// Returns whether a new year was selected.
    public mutating func selectYear(_ yearTagID: Tag.ID?) -> Bool {
        guard self.yearTagID != yearTagID else {
            return false
        }
        self = .init(yearTagID: yearTagID)
        return true
    }
}

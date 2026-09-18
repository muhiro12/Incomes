import Foundation

/// Draft values that invalidate a reviewed balance projection when they change.
struct ItemFormDraftChangeKey: Equatable {
    let input: ItemFormInput
    let repeatMonthSelections: Set<RepeatMonthSelection>
}

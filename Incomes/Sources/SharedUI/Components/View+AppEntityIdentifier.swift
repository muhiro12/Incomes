import AppIntents
import SwiftUI

extension View {
    /// Tells Siri and Apple Intelligence which item this view shows, so a
    /// request about "this item" resolves to the same `ItemEntity` that
    /// App Intents use.
    @ViewBuilder
    func itemEntityIdentifier(_ item: Item) -> some View {
        if #available(iOS 18.4, *) {
            appEntityIdentifier(ItemEntity.entityIdentifier(for: item))
        } else {
            self
        }
    }

    /// Tells Siri and Apple Intelligence which tag this view shows, so a
    /// request about "this category" resolves to its `TagEntity`.
    @ViewBuilder
    func tagEntityIdentifier(_ tag: Tag) -> some View {
        if #available(iOS 18.4, *) {
            appEntityIdentifier(TagEntity.entityIdentifier(for: tag))
        } else {
            self
        }
    }
}

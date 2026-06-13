import SwiftUI

struct OrphanTagSection: View {
    let title: LocalizedStringKey
    let orphanTags: [Tag]

    @Binding var selectedTagID: Tag.ID?

    var body: some View {
        if !orphanTags.isEmpty {
            Section(title) {
                ForEach(orphanTags) { tag in
                    OrphanTagRow(
                        tag: tag,
                        selectedTagID: $selectedTagID
                    )
                }
            }
        }
    }
}

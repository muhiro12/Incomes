import SwiftUI

struct DuplicateTagSection: View {
    let title: LocalizedStringKey
    let duplicates: [Tag]

    @Binding var selectedTagID: Tag.ID?
    @Binding var selectedTags: [Tag]
    @Binding var isResolveDialogPresented: Bool

    var body: some View {
        if !duplicates.isEmpty {
            Section {
                ForEach(duplicates) { tag in
                    DuplicateTagRow(
                        tag: tag,
                        selectedTagID: $selectedTagID,
                        selectedTags: $selectedTags,
                        isResolveDialogPresented: $isResolveDialogPresented
                    )
                }
            } header: {
                DuplicateTagSectionHeader(
                    title: title,
                    duplicates: duplicates,
                    selectedTags: $selectedTags,
                    isResolveDialogPresented: $isResolveDialogPresented
                )
            }
        }
    }
}

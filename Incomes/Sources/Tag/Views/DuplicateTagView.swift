import SwiftData
import SwiftUI

struct DuplicateTagView: View {
    @Environment(\.modelContext)
    private var context

    @BridgeQuery private var tags: [TagEntity]

    @State private var isMergeDialogPresented = false
    @State private var isDeleteDialogPresented = false
    @State private var selectedTag: Tag?

    init(_ tag: Tag) {
        _tags = .init(.tags(.isSameWith(tag)))
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                let tagModels = tags.compactMap { try? $0.model(in: context) }
                ForEach(tagModels) { tag in
                    List {
                        Section {
                            ForEach(tag.items ?? []) { item in
                                Text(item.content)
                            }
                        } header: {
                            HStack {
                                Text("\(tag.items?.count ?? .zero) Items")
                                Spacer()
                                Button {
                                    isDeleteDialogPresented = true
                                    selectedTag = tag
                                } label: {
                                    Label {
                                        Text("Delete")
                                    } icon: {
                                        Image(systemName: "trash")
                                    }
                                }
                                .font(.caption)
                                .textCase(nil)
                            }
                        }
                    }
                    .frame(width: .componentXL)
                    if tag.id != tagModels.last?.id {
                        Divider()
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            Text("Merge"),
            isPresented: $isMergeDialogPresented
        ) {
            Button {
                do {
                    try MergeDuplicateTagsIntent.perform(
                        (
                            context: context,
                            tags: tags
                        )
                    )
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Merge")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to merge these tags? This action cannot be undone.")
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                guard let selectedTag else {
                    return
                }
                do {
                    try DeleteTagIntent.perform(
                        (
                            context: context,
                            tag: .init(selectedTag)!
                        )
                    )
                    self.selectedTag = nil
                    Haptic.success.impact()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this tag? This action cannot be undone.")
        }
        .toolbar {
            ToolbarItem {
                Button {
                    isMergeDialogPresented = true
                } label: {
                    Text("Merge")
                }
            }
            ToolbarItem {
                CloseButton()
            }
            ToolbarItem(placement: .status) {
                Text("\(tags.count) Items")
                    .font(.footnote)
            }
        }
        .navigationTitle(Text(tags.first?.displayName ?? ""))
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicateTagNavigationView()
    }
}

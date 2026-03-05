import SwiftData
import SwiftUI

struct DuplicateTagView: View {
    @Query private var tags: [Tag]

    @State private var isMergeDialogPresented = false
    @State private var isDeleteDialogPresented = false
    @State private var selectedTag: Tag?

    init(_ tag: Tag) { // swiftlint:disable:this type_contents_order
        _tags = Query(.tags(.isSameWith(tag)))
    }

    var body: some View {
        ScrollView(.horizontal) { // swiftlint:disable:this closure_body_length
            LazyHStack(spacing: .zero) {
                ForEach(tags) { tag in
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
                                        Image(systemName: "trash") // swiftlint:disable:this accessibility_label_for_image line_length
                                    }
                                }
                                .font(.caption)
                                .textCase(nil)
                            }
                        }
                    }
                    .frame(width: .component(.xl))
                    if tag.id != tags.last?.id {
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
                TagService.mergeDuplicates(tags: tags)
            } label: {
                Text("Merge")
            }
            Button(role: .cancel) {
                // no-op
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
                TagService.delete(tag: selectedTag)
                self.selectedTag = nil
                Haptic.success.impact()
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                // no-op
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
            StatusToolbarItem("\(tags.count) Items")
        }
        .navigationTitle(tags.first?.displayName ?? "")
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    DuplicateTagNavigationView()
}

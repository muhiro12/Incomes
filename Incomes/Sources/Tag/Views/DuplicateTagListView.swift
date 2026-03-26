import SwiftData
import SwiftUI

struct DuplicateTagListView: View {
    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]
    @Query(.tags(.typeIs(.yearMonth)))
    private var yearMonthTags: [Tag]
    @Query(.tags(.typeIs(.content)))
    private var contentTags: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categoryTags: [Tag]

    @Binding private var selectedTagID: Tag.ID?

    @State private var isResolveDialogPresented = false
    @State private var selectedTags = [Tag]()

    init(selection: Binding<Tag.ID?> = .constant(nil)) { // swiftlint:disable:this type_contents_order
        _selectedTagID = selection
    }

    var body: some View {
        List(selection: $selectedTagID) {
            buildSection(from: yearTags) {
                Text("Year")
            }
            buildSection(from: yearMonthTags) {
                Text("YearMonth")
            }
            buildSection(from: contentTags) {
                Text("Content")
            }
            buildSection(from: categoryTags) {
                Text("Category")
            }
        }
        .confirmationDialog(
            Text("Resolve All"),
            isPresented: $isResolveDialogPresented
        ) {
            Button {
                do {
                    try TagService.resolveDuplicates(
                        context: context,
                        tags: selectedTags
                    )
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Resolve")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to resolve all duplicate tags? This action cannot be undone.")
        }
        .navigationTitle("Duplicate Tags")
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }

    private func buildSection<Header: View>(from tags: [Tag], header: () -> Header) -> some View {
        let duplicates: [Tag]
        do {
            let type = tags.first?.type
            duplicates = try {
                if let type {
                    return try TagService.duplicateTags(
                        context: context,
                        type: type
                    )
                }
                return []
            }()
            .sorted { left, right in
                left.displayName < right.displayName
            }
        } catch {
            assertionFailure(error.localizedDescription)
            duplicates = []
        }

        if duplicates.isEmpty {
            return AnyView(EmptyView())
        }
        return AnyView(
            Section {
                ForEach(duplicates) { tag in
                    HStack {
                        Text(tag.displayName)
                        Spacer()
                        Text(tag.items.orEmpty.count.description)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .tag(tag.persistentModelID)
                }
            } header: {
                HStack {
                    header()
                    Spacer()
                    Button {
                        isResolveDialogPresented = true
                        selectedTags = duplicates
                    } label: {
                        Text("Resolve All")
                    }
                    .font(.caption)
                    .textCase(nil)
                }
            }
        )
    }
}

#Preview(traits: .modifier(IncomesDuplicateTagSampleData())) {
    DuplicateTagListView()
}

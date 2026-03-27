import SwiftData
import SwiftUI

struct DebugTagListView: View {
    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]
    @Query(.tags(.typeIs(.yearMonth)))
    private var yearMonthTags: [Tag]
    @Query(.tags(.typeIs(.content)))
    private var contentTags: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categoryTags: [Tag]

    @Binding private var selectedTagID: Tag.ID?

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
    }

    @ViewBuilder
    private func buildSection<Header: View>(from tags: [Tag], header: () -> Header) -> some View {
        Section {
            ForEach(tags) { tag in
                Text(tag.displayName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button("Inspect", systemImage: "arrow.right.circle") {
                            selectedTagID = tag.persistentModelID
                        }
                        CopyTextContextMenuButton(
                            "Copy Name",
                            text: tag.displayName
                        )
                    }
                    .tag(tag.persistentModelID)
            }
        } header: {
            header()
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    DebugTagListView()
}

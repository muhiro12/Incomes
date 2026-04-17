import SwiftData
import SwiftUI

struct DebugAllTagsView: View {
    @Binding private var selectedTagID: Tag.ID?

    init(selection: Binding<Tag.ID?> = .constant(nil)) { // swiftlint:disable:this type_contents_order
        _selectedTagID = selection
    }

    var body: some View {
        DebugTagListView(selection: $selectedTagID)
            .navigationTitle("All Tags")
            .toolbar {
                ToolbarItem {
                    CloseButton()
                }
            }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        DebugAllTagsView()
    }
}

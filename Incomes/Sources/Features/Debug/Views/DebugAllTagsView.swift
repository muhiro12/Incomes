import SwiftData
import SwiftUI

struct DebugAllTagsView: View {
    @Binding private var selectedTagID: Tag.ID?

    init(selection: Binding<Tag.ID?> = .constant(nil)) {
        _selectedTagID = selection
    }
}

extension DebugAllTagsView {
    @ViewBuilder var body: some View {
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

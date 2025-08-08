import SwiftUI

struct DuplicateTagNavigationView: View {
    @Environment(\.modelContext)
    private var context
    @State private var detail: Tag?

    var body: some View {
        NavigationSplitView {
            DuplicateTagListView(selection: $detail)
        } detail: {
            if let detail {
                DuplicateTagView(detail)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicateTagNavigationView()
    }
}

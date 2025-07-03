import SwiftUI

struct DuplicateTagNavigationView: View {
    @Environment(\.modelContext)
    private var context
    @State private var detail: TagEntity?

    var body: some View {
        NavigationSplitView {
            DuplicateTagListView(selection: $detail)
        } detail: {
            if let detail,
               let tag = try? detail.model(in: context)
            {
                DuplicateTagView(tag)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicateTagNavigationView()
    }
}

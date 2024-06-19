import SwiftUI

struct DuplicateTagsNavigationView: View {
    @State private var detail: Tag?

    var body: some View {
        NavigationSplitView {
            DuplicateTagsView(selection: $detail)
        } detail: {
            if let detail {
                DuplicateTagView(detail)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicateTagsNavigationView()
    }
}

import SwiftUI

struct DuplicatedTagsNavigationView: View {
    @State private var detail: Tag?
    
    var body: some View {
        NavigationSplitView {
            DuplicatedTagsView(selection: $detail)
        } detail: {
            if let detail {
                DuplicatedTagView(detail)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicatedTagsNavigationView()
    }
}

import SwiftUI

struct DuplicateTagNavigationView: View {
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

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    DuplicateTagNavigationView()
}

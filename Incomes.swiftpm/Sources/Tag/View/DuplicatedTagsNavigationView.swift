import SwiftUI

struct DuplicatedTagsNavigationView: View {
    var body: some View {
        NavigationStack {
            DuplicatedTagsView()
                .incomesNavigationDestination()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicatedTagsNavigationView()
    }
}

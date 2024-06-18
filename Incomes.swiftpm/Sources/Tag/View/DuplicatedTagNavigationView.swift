import SwiftUI

struct DuplicatedTagNavigationView: View {
    var body: some View {
        NavigationStack {
            DuplicatedTagsView()
                .incomesNavigationDestination()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicatedTagNavigationView()
    }
}

import SwiftUI

/// Returns to the calling screen without replacing its navigation path.
struct SubscriptionSheet: View {
    var body: some View {
        NavigationStack {
            StoreListView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        CloseButton()
                    }
                }
        }
        .incomesSheetPresentation()
    }
}

import SwiftData
import SwiftUI

struct ItemPreviewNavigationView {}

extension ItemPreviewNavigationView: View {
    var body: some View {
        NavigationStack {
            ItemPreviewView()
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    ItemPreviewNavigationView()
        .environment(items[0])
}

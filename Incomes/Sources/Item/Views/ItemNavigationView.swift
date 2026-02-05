import SwiftData
import SwiftUI

struct ItemNavigationView {}

extension ItemNavigationView: View {
    var body: some View {
        NavigationStack {
            ItemView()
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    ItemNavigationView()
        .environment(items[0])
}

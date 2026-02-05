import SwiftData
import SwiftUI

struct ItemPreviewView {
    @Environment(Item.self)
    private var item
}

extension ItemPreviewView: View {
    var body: some View {
        List {
            ItemSection()
        }
        .navigationTitle(item.content)
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    NavigationStack {
        ItemPreviewView()
            .environment(items[0])
    }
}

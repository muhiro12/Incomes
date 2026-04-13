import MHPlatform
import SwiftData
import SwiftUI

struct ItemView {
    @Environment(Item.self)
    private var item
    @Environment(\.isPresented)
    private var isPresented

    @AppStorage(\.isDebugOn)
    private var isDebugOn
}

extension ItemView: View {
    var body: some View {
        List {
            ItemSection()
            if isDebugOn {
                DebugSection()
            }
            Section {
                EditItemButton()
                DuplicateItemButton()
                DeleteItemButton()
            }
        }
        .contentMargins(.bottom, .space(.s), for: .scrollContent)
        .toolbarRole(.editor)
        .navigationTitle(item.content)
        .toolbar {
            if isPresented {
                ToolbarItem {
                    CloseButton()
                }
            }
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    NavigationStack {
        ItemView()
            .environment(items[0])
    }
}

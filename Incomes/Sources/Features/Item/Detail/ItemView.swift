import MHDesign
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
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let showsCloseButton: Bool

    init(showsCloseButton: Bool = true) {
        self.showsCloseButton = showsCloseButton
    }
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
        .contentMargins(.bottom, designMetrics.spacing.inline, for: .scrollContent)
        .navigationTitle(item.content)
        .itemEntityIdentifier(item)
        .toolbar {
            if showsCloseButton, isPresented {
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

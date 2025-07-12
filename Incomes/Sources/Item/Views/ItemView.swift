import SwiftUI

struct ItemView {
    @Environment(ItemEntity.self)
    private var item
    @Environment(\.isPresented)
    private var isPresented

    @AppStorage(.isDebugOn)
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
        .navigationTitle(Text(item.content))
        .toolbar {
            if isPresented {
                ToolbarItem {
                    CloseButton()
                }
            }
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            ItemView()
                .environment(preview.items[0])
        }
    }
}

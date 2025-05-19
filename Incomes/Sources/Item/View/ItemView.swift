import SwiftUI
import SwiftUtilities

struct ItemView {
    @Environment(Item.self)
    private var item
    @Environment(\.isPresented)
    private var isPresented

    @AppStorage(.isDebugOn)
    private var isDebugOn
}

extension ItemView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(item.localDate.stringValue(.yyyyMMMd))
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Income")
                    Spacer()
                    Text(item.income.asCurrency)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Outgo")
                    Spacer()
                    Text(item.outgo.asMinusCurrency)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Category")
                    Spacer()
                    Text(item.category?.displayName ?? .empty)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Information")
            }
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

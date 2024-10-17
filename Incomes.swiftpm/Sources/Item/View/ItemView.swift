import SwiftUI
import SwiftUtilities

struct ItemView {
    @Environment(Item.self)
    private var item

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var isEditFormPresented = false
    @State private var isDuplicateFormPresented = false
}

extension ItemView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(item.date.stringValue(.yyyyMMMd))
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
                Button {
                    isEditFormPresented = true
                } label: {
                    Text("Edit")
                }
                .frame(maxWidth: .infinity)
                Button {
                    isDuplicateFormPresented = true
                } label: {
                    Text("Duplicate")
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(Text(item.content))
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .sheet(isPresented: $isEditFormPresented) {
            ItemFormNavigationView(mode: .edit)
        }
        .sheet(isPresented: $isDuplicateFormPresented) {
            ItemFormNavigationView(mode: .create)
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

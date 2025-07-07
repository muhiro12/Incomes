import SwiftUI

struct DebugTagView: View {
    @Environment(TagEntity.self)
    private var tag
    @Environment(\.modelContext)
    private var context

    var body: some View {
        List {
            Section {
                Text(tag.displayName)
            } header: {
                Text("Display Name")
            }
            Section {
                Text(tag.name)
            } header: {
                Text("Name")
            }
            if let type = tag.type {
                Section {
                    Text(String(describing: type))
                } header: {
                    Text("Type")
                }
            }
            Section {
                Text(tag.typeID)
            } header: {
                Text("Type ID")
            }
            Section {
                ForEach(items) { item in
                    NavigationLink {
                        ItemFormView(mode: .edit)
                            .environment(item)
                    } label: {
                        Text(item.content)
                    }
                }
            } header: {
                Text("Items")
            }
        }
        .navigationTitle(tag.displayName)
    }
}

private extension DebugTagView {
    var items: [ItemEntity] {
        (
            try? tag.model(in: context).items.orEmpty.compactMap(ItemEntity.init)
        ).orEmpty
    }
}

#Preview {
    IncomesPreview { preview in
        DebugTagView()
            .environment(preview.tags[0])
    }
}

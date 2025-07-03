import SwiftUI
import SwiftUtilities

struct ItemPreviewView {
    @Environment(ItemEntity.self)
    private var item
}

extension ItemPreviewView: View {
    var body: some View {
        List {
            ItemSection()
        }
        .navigationTitle(Text(item.content))
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            ItemPreviewView()
                .environment(ItemEntity(preview.items[0])!)
        }
    }
}

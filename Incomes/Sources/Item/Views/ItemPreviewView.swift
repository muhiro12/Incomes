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
        .navigationTitle(Text(item.content))
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            ItemPreviewView()
                .environment(preview.items[0])
        }
    }
}

import SwiftUI

struct ItemNavigationView {
    @Environment(Item.self)
    private var item
}

extension ItemNavigationView: View {
    var body: some View {
        NavigationStack {
            ItemView()
        }
    }
}

#Preview {
    IncomesPreview { preview in
        ItemNavigationView()
            .environment(preview.items[0])        
    }
}

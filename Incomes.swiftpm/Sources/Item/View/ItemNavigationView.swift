import SwiftUI

struct ItemNavigationView {}

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

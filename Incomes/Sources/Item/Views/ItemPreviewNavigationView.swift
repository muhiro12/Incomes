import SwiftUI

struct ItemPreviewNavigationView {}

extension ItemPreviewNavigationView: View {
    var body: some View {
        NavigationStack {
            ItemPreviewView()
        }
    }
}

#Preview {
    IncomesPreview { preview in
        ItemPreviewNavigationView()
            .environment(preview.items[0])
    }
}

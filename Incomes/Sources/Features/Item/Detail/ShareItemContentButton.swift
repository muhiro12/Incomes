import SwiftUI

struct ShareItemContentButton: View {
    @Environment(Item.self)
    private var item

    @State private var isPresented = false

    var action: (() -> Void)?

    var body: some View {
        Button("Copy or Share Content", systemImage: "doc.on.doc") {
            if let action {
                action()
            } else {
                isPresented = true
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                ItemContentShareView()
                    .environment(item)
            }
            .incomesSheetPresentation()
        }
    }
}

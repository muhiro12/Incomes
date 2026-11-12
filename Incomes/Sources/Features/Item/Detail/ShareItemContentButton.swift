import SwiftUI

struct ShareItemContentButton: View {
    @Environment(Item.self)
    private var item

    @State private var isPresented = false

    var action: (() -> Void)?

    var body: some View {
        Button("Copy Content…", systemImage: "clipboard") {
            if let action {
                action()
            } else {
                isPresented = true
            }
        }
        .accessibilityHint(Text("Review content before copying or sharing."))
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                ItemContentShareView()
                    .environment(item)
            }
            .incomesSheetPresentation()
        }
    }
}

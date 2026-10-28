import SwiftUI

struct ExportItemTemplateButton: View {
    @Environment(Item.self)
    private var item

    @State private var isPresented = false

    var action: (() -> Void)?

    var body: some View {
        Button("Export Template", systemImage: "doc.text") {
            if let action {
                action()
            } else {
                isPresented = true
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                ItemTemplateExportView()
                    .environment(item)
            }
            .incomesSheetPresentation()
        }
    }
}

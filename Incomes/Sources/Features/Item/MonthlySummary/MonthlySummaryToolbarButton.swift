import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryToolbarButton: View {
    @State private var isPopoverPresented = false

    let date: Date
    let currentItems: [Item]
    let previousItems: [Item]

    var body: some View {
        Button {
            isPopoverPresented = true
        } label: {
            Label("Monthly Summary", systemImage: "sparkles")
        }
        .accessibilityLabel(Text("Monthly Summary"))
        .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
            MonthlySummaryPopover(
                date: date,
                currentItems: currentItems,
                previousItems: previousItems
            )
            .presentationCompactAdaptation(.popover)
        }
    }
}

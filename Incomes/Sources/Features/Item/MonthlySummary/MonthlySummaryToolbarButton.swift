import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryToolbarButton: View {
    @State private var isPopoverPresented = false

    let generatedSummary: MonthlySummaryResult?
    let isGenerating: Bool
    let errorMessage: String?
    let generateSummary: () -> Void

    var body: some View {
        Button {
            isPopoverPresented = true
        } label: {
            Label("Monthly Summary", systemImage: "sparkles")
        }
        .accessibilityLabel(Text("Monthly Summary"))
        .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
            MonthlySummaryPopover(
                generatedSummary: generatedSummary,
                isGenerating: isGenerating,
                errorMessage: errorMessage,
                generateSummary: generateSummary
            )
            .presentationCompactAdaptation(.popover)
        }
    }
}

import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryToolbarButton: View {
    let generatedSummary: String?
    let isGenerating: Bool
    @Binding var isPopoverPresented: Bool
    let generateInitialSummary: () -> Void
    let generateSummary: () -> Void

    var body: some View {
        Button {
            isPopoverPresented = true
            generateInitialSummary()
        } label: {
            if isWaitingForInitialSummary {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: "sparkles")
            }
        }
        .accessibilityLabel(Text("Monthly Summary"))
        .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
            MonthlySummaryPopover(
                generatedSummary: generatedSummary,
                isGenerating: isGenerating,
                generateSummary: generateSummary
            )
            .presentationCompactAdaptation(.popover)
        }
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryToolbarButton {
    var isWaitingForInitialSummary: Bool {
        isGenerating && generatedSummary == nil
    }
}

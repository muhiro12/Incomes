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
        .incomesSecondaryControlStyle()
        .accessibilityLabel(accessibilityLabel)
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

    var accessibilityLabel: Text {
        if isWaitingForInitialSummary {
            return Text("Generating Summary")
        }
        return Text("Monthly Summary")
    }
}

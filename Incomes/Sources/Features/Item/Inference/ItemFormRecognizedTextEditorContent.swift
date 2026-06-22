import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormRecognizedTextEditorContent: View {
    private enum Constants {
        static let minimumHeight: CGFloat = 220
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var recognizedText: String

    var body: some View {
        TextEditor(text: $recognizedText)
            .scrollContentBackground(.hidden)
            .frame(minHeight: Constants.minimumHeight)
            .padding(.horizontal, designMetrics.layout.surface.compactInsetHorizontal)
            .padding(.vertical, designMetrics.layout.surface.compactInsetVertical)
            .incomesGlassEffect(
                cornerRadius: designMetrics.cornerRadius.surface,
                isInteractive: true
            )
            .accessibilityLabel("Captured text")
    }
}

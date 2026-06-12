import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormRecognizedTextEditor: View {
    private enum Constants {
        static let borderLineWidth: CGFloat = 1
        static let borderOpacity = 0.18
        static let minimumHeight: CGFloat = 220
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var recognizedText: String

    let isRecognizedTextEmpty: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            textEditor
            if isRecognizedTextEmpty {
                placeholderText
                    .allowsHitTesting(false)
            }
        }
        .overlay(editorBorder)
    }
}

@available(iOS 26.0, *)
private extension ItemFormRecognizedTextEditor {
    var textEditor: some View {
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

    var placeholderText: some View {
        Text("Paste or capture text to extract details.")
            .foregroundStyle(.secondary)
            .padding(.top, designMetrics.layout.surface.compactInsetVertical)
            .padding(.leading, designMetrics.layout.surface.compactInsetHorizontal)
    }

    var editorBorder: some View {
        RoundedRectangle(
            cornerRadius: designMetrics.cornerRadius.surface,
            style: .continuous
        )
        .stroke(
            Color.secondary.opacity(Constants.borderOpacity),
            lineWidth: Constants.borderLineWidth
        )
    }
}

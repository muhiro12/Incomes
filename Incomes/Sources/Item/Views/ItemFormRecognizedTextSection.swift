import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormRecognizedTextSection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var recognizedText: String

    let isRecognizedTextEmpty: Bool

    private let cardBorderLineWidth: CGFloat = 1
    private let cardBorderOpacity = 0.18
    private let textEditorMinimumHeight: CGFloat = 220

    var body: some View {
        Section {
            recognizedTextEditor
                .listRowInsets(rowInsets)
        } header: {
            Text("Recognized Text")
        } footer: {
            Text("We will extract date, amounts, category, and priority from this text.")
        }
    }
}

@available(iOS 26.0, *)
private extension ItemFormRecognizedTextSection {
    var recognizedTextEditor: some View {
        ZStack(alignment: .topLeading) {
            if isRecognizedTextEmpty {
                placeholderText
            }

            TextEditor(text: $recognizedText)
                .scrollContentBackground(.hidden)
                .frame(minHeight: textEditorMinimumHeight)
                .padding(.horizontal, designMetrics.layout.surface.compactInsetHorizontal)
                .padding(.vertical, designMetrics.layout.surface.compactInsetVertical)
                .background(editorBackground)
                .accessibilityLabel("Captured text")
        }
        .overlay(editorBorder)
    }

    var placeholderText: some View {
        Text("Paste or capture text to extract details.")
            .foregroundStyle(.secondary)
            .padding(.top, designMetrics.layout.surface.compactInsetVertical)
            .padding(.leading, designMetrics.layout.surface.compactInsetHorizontal)
    }

    var editorBackground: some View {
        RoundedRectangle(
            cornerRadius: designMetrics.cornerRadius.surface,
            style: .continuous
        )
        .fill(Color(uiColor: .secondarySystemBackground))
    }

    var editorBorder: some View {
        RoundedRectangle(
            cornerRadius: designMetrics.cornerRadius.surface,
            style: .continuous
        )
        .stroke(
            Color.secondary.opacity(cardBorderOpacity),
            lineWidth: cardBorderLineWidth
        )
    }

    var rowInsets: EdgeInsets {
        .init(
            top: designMetrics.layout.surface.compactInsetVertical,
            leading: designMetrics.layout.surface.compactInsetHorizontal,
            bottom: designMetrics.layout.surface.compactInsetVertical,
            trailing: designMetrics.layout.surface.compactInsetHorizontal
        )
    }
}

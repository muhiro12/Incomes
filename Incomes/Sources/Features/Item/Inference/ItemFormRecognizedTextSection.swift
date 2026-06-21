import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormRecognizedTextSection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var recognizedText: String

    let isRecognizedTextEmpty: Bool

    var body: some View {
        Section {
            ItemFormRecognizedTextEditor(
                recognizedText: $recognizedText,
                isRecognizedTextEmpty: isRecognizedTextEmpty
            )
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
    var rowInsets: EdgeInsets {
        .init(
            top: designMetrics.layout.surface.compactInsetVertical,
            leading: designMetrics.layout.surface.compactInsetHorizontal,
            bottom: designMetrics.layout.surface.compactInsetVertical,
            trailing: designMetrics.layout.surface.compactInsetHorizontal
        )
    }
}

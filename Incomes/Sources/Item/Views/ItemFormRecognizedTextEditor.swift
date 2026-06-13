import SwiftUI

@available(iOS 26.0, *)
struct ItemFormRecognizedTextEditor: View {
    @Binding var recognizedText: String

    let isRecognizedTextEmpty: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            ItemFormRecognizedTextEditorContent(
                recognizedText: $recognizedText
            )
            if isRecognizedTextEmpty {
                ItemFormRecognizedTextEditorPlaceholder()
                    .allowsHitTesting(false)
            }
        }
        .overlay(ItemFormRecognizedTextEditorBorder())
    }
}

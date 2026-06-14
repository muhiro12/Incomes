import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistCameraButton: View {
    let isImportDisabled: Bool
    let openCamera: () -> Void

    var body: some View {
        Button(action: openCamera) {
            Label("Camera", systemImage: "camera")
                .frame(maxWidth: .infinity)
        }
        .labelStyle(.titleAndIcon)
        .incomesSecondaryControlStyle()
        .disabled(isImportDisabled)
        .accessibilityHint(Text("Captures an image to scan text."))
    }
}

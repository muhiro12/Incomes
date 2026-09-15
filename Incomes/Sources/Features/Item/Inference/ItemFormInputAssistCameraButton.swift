import SwiftUI
import UIKit

@available(iOS 26.0, *)
struct ItemFormInputAssistCameraButton: View {
    let isImportDisabled: Bool
    let openCamera: () -> Void

    var body: some View {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            Button {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    openCamera()
                }
            } label: {
                Label("Camera", systemImage: "camera")
                    .frame(maxWidth: .infinity)
            }
            .labelStyle(.titleAndIcon)
            .incomesSecondaryControlStyle()
            .disabled(isImportDisabled)
            .accessibilityHint(accessibilityHint)
        }
    }
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistCameraButton {
    var accessibilityHint: Text {
        if isImportDisabled {
            return Text("Wait for the current text capture to finish.")
        }
        return Text("Captures an image to scan text.")
    }
}

import PhotosUI
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistPhotoLibraryPicker: View {
    @Binding var selectedItem: PhotosPickerItem?

    let isImportDisabled: Bool

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Label("Photo Library", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
        }
        .labelStyle(.titleAndIcon)
        .incomesSecondaryControlStyle()
        .disabled(isImportDisabled)
        .accessibilityHint(accessibilityHint)
    }
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistPhotoLibraryPicker {
    var accessibilityHint: Text {
        if isImportDisabled {
            return Text("Wait for the current text capture to finish.")
        }
        return Text("Chooses an image to scan text.")
    }
}

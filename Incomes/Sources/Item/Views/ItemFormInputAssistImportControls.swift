import PhotosUI
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistImportControls: View {
    @Binding var selectedItem: PhotosPickerItem?
    let isImportDisabled: Bool
    let controlSpacing: CGFloat
    let openCamera: () -> Void

    var body: some View {
        IncomesLiquidGlassControlGroup(spacing: controlSpacing) {
            ViewThatFits {
                horizontalLayout
                verticalLayout
            }
        }
    }
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistImportControls {
    var horizontalLayout: some View {
        HStack(spacing: controlSpacing) {
            photoLibraryPicker
            cameraButton
        }
    }

    var verticalLayout: some View {
        VStack(alignment: .leading, spacing: controlSpacing) {
            photoLibraryPicker
            cameraButton
        }
    }

    var photoLibraryPicker: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Label("Photo Library", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
        }
        .labelStyle(.titleAndIcon)
        .incomesSecondaryControlStyle()
        .disabled(isImportDisabled)
    }

    var cameraButton: some View {
        Button(action: openCamera) {
            Label("Camera", systemImage: "camera")
                .frame(maxWidth: .infinity)
        }
        .labelStyle(.titleAndIcon)
        .incomesSecondaryControlStyle()
        .disabled(isImportDisabled)
    }
}

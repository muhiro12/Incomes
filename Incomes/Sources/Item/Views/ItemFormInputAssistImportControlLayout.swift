import PhotosUI
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistImportControlLayout: View {
    @Binding var selectedItem: PhotosPickerItem?

    let isImportDisabled: Bool
    let controlSpacing: CGFloat
    let openCamera: () -> Void

    var body: some View {
        ViewThatFits {
            HStack(spacing: controlSpacing) {
                ItemFormInputAssistPhotoLibraryPicker(
                    selectedItem: $selectedItem,
                    isImportDisabled: isImportDisabled
                )
                ItemFormInputAssistCameraButton(
                    isImportDisabled: isImportDisabled,
                    openCamera: openCamera
                )
            }

            VStack(alignment: .leading, spacing: controlSpacing) {
                ItemFormInputAssistPhotoLibraryPicker(
                    selectedItem: $selectedItem,
                    isImportDisabled: isImportDisabled
                )
                ItemFormInputAssistCameraButton(
                    isImportDisabled: isImportDisabled,
                    openCamera: openCamera
                )
            }
        }
    }
}

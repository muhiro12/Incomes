import PhotosUI
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistImportSection: View {
    @Binding private var selectedItem: PhotosPickerItem?

    private let isImportDisabled: Bool
    private let openCamera: () -> Void

    init(
        selectedItem: Binding<PhotosPickerItem?>,
        isImportDisabled: Bool,
        openCamera: @escaping () -> Void
    ) {
        _selectedItem = selectedItem
        self.isImportDisabled = isImportDisabled
        self.openCamera = openCamera
    }
}

@available(iOS 26.0, *)
extension ItemFormInputAssistImportSection {
    @ViewBuilder var body: some View {
        Section {
            ItemFormInputAssistPhotoLibraryPicker(
                selectedItem: $selectedItem,
                isImportDisabled: isImportDisabled
            )
            ItemFormInputAssistCameraButton(
                isImportDisabled: isImportDisabled,
                openCamera: openCamera
            )
        } header: {
            Text("Import")
        }
    }
}

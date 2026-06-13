import PhotosUI
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistImportSection: View {
    @Binding private var selectedItem: PhotosPickerItem?

    private let isImportDisabled: Bool
    private let openCamera: () -> Void

    init( // swiftlint:disable:this type_contents_order
        selectedItem: Binding<PhotosPickerItem?>,
        isImportDisabled: Bool,
        openCamera: @escaping () -> Void
    ) {
        _selectedItem = selectedItem
        self.isImportDisabled = isImportDisabled
        self.openCamera = openCamera
    }

    var body: some View {
        Section {
            photoLibraryPicker
            cameraButton
        } header: {
            Text("Import")
        }
    }
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistImportSection {
    var photoLibraryPicker: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Label("Photo Library", systemImage: "photo.on.rectangle")
        }
        .labelStyle(.titleAndIcon)
        .disabled(isImportDisabled)
    }

    var cameraButton: some View {
        Button(action: openCamera) {
            Label("Camera", systemImage: "camera")
        }
        .labelStyle(.titleAndIcon)
        .disabled(isImportDisabled)
    }
}

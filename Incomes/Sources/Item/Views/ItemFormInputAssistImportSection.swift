import MHDesign
import PhotosUI
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistImportSection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

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
            ItemFormInputAssistImportControls(
                selectedItem: $selectedItem,
                isImportDisabled: isImportDisabled,
                controlSpacing: designMetrics.spacing.control,
                openCamera: openCamera
            )
            .listRowInsets(rowInsets)
        } header: {
            Text("Import")
        }
    }
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistImportSection {
    var rowInsets: EdgeInsets {
        .init(
            top: designMetrics.layout.surface.compactInsetVertical,
            leading: designMetrics.layout.surface.compactInsetHorizontal,
            bottom: designMetrics.layout.surface.compactInsetVertical,
            trailing: designMetrics.layout.surface.compactInsetHorizontal
        )
    }
}

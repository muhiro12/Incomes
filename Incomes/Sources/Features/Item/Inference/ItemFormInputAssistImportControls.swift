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
            ItemFormInputAssistImportControlLayout(
                selectedItem: $selectedItem,
                isImportDisabled: isImportDisabled,
                controlSpacing: controlSpacing,
                openCamera: openCamera
            )
        }
    }
}

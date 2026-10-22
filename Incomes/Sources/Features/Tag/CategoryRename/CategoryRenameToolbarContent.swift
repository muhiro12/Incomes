import SwiftUI

struct CategoryRenameToolbarContent: ToolbarContent {
    let canSave: Bool
    let cancel: () -> Void
    let save: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark", action: cancel)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save", systemImage: "checkmark", action: save)
                .disabled(!canSave)
        }
    }
}

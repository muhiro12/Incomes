import SwiftData
import SwiftUI

struct ItemContextMenuActions {
    @Environment(Item.self)
    private var item

    private let showAction: (() -> Void)?
    private let editAction: (() -> Void)?
    private let duplicateAction: (() -> Void)?
    private let deleteAction: (() -> Void)?
    private let exportTemplateAction: (() -> Void)?

    init(
        showAction: (() -> Void)? = nil,
        editAction: (() -> Void)? = nil,
        duplicateAction: (() -> Void)? = nil,
        deleteAction: (() -> Void)? = nil,
        exportTemplateAction: (() -> Void)? = nil
    ) {
        self.showAction = showAction
        self.editAction = editAction
        self.duplicateAction = duplicateAction
        self.deleteAction = deleteAction
        self.exportTemplateAction = exportTemplateAction
    }
}

extension ItemContextMenuActions: View {
    var body: some View {
        ShowItemButton(action: showAction)
        EditItemButton(action: editAction)
        DuplicateItemButton(action: duplicateAction)
        RecalculateItemButton()
        ExportItemTemplateButton(action: exportTemplateAction)
        if let itemURL = MainNavigationOperations.preferredURL(for: item) {
            Divider()
            ShareLink(item: itemURL) {
                Label("Share Link", systemImage: "square.and.arrow.up")
            }
            CopyURLContextMenuButton("Copy Link", url: itemURL)
        }
        Divider()
        DeleteItemButton(action: deleteAction)
    }
}

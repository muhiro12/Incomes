import SwiftUI

struct OrphanTagView: View {
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    @Environment(Tag.self)
    private var tag

    @State private var isDeleteDialogPresented = false

    let onDelete: () -> Void

    var body: some View {
        List {
            Section("Display Name") {
                Text(tag.displayName)
            }
            Section("Name") {
                Text(!tag.name.isEmpty ? tag.name : "(empty)")
            }
            if let type = tag.type {
                Section("Type") {
                    Text(typeTitle(type))
                }
            }
            Section("Items") {
                Text("0")
            }
            Section("Description") {
                Text("This unused tag is no longer referenced by any items.")
            }
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                guard
                    LedgerAccessOperations.canEdit(
                        ledgerIdentifier,
                        isPremium: LedgerMutationAccess.isPremium
                    )
                else {
                    return
                }
                if TagMutationOperations.delete(tag: tag) {
                    onDelete()
                    Haptic.success.impact()
                } else {
                    Haptic.warning.impact()
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this orphan tag? This action cannot be undone.")
        }
        .navigationTitle(tag.displayName)
        .toolbar {
            ToolbarItem {
                Button(role: .destructive) {
                    isDeleteDialogPresented = true
                } label: {
                    Text("Delete")
                }
                .ledgerWriteAccess(owner: ledgerIdentifier)
            }
            ToolbarItem {
                CloseButton()
            }
            ItemCountStatusToolbarItem(count: .zero)
        }
    }
}

private extension OrphanTagView {
    func typeTitle(
        _ type: TagType
    ) -> String {
        switch type {
        case .year:
            "Year"
        case .yearMonth:
            "YearMonth"
        case .content:
            "Content"
        case .category:
            "Category"
        case .debug:
            "Debug"
        case .ledger:
            "Ledger"
        }
    }
}

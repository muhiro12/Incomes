import SwiftUI

struct OrphanTagView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(Tag.self)
    private var tag

    @State private var isDeleteDialogPresented = false
    @State private var errorAlertPresentation: ErrorAlertPresentation?

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
                deleteTag()
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
        .incomesErrorAlert($errorAlertPresentation)
        .navigationTitle(tag.displayName)
        .toolbar {
            ToolbarItem {
                Button(role: .destructive) {
                    isDeleteDialogPresented = true
                } label: {
                    Text("Delete")
                }
            }
            ToolbarItem {
                CloseButton()
            }
            ItemCountStatusToolbarItem(count: .zero)
        }
    }
}

private extension OrphanTagView {
    func deleteTag() {
        do {
            guard try TagMutationOperations.delete(
                context: context,
                tag: tag
            ) else {
                Haptic.warning.impact()
                return
            }

            onDelete()
            Haptic.success.impact()
        } catch {
            errorAlertPresentation = .init(
                title: "Unable to Update Tags",
                error: error
            )
        }
    }

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
        }
    }
}

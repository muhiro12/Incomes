//
//  DeleteItemButton.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/18/24.
//

import SwiftUI

struct DeleteItemButton {
    @Environment(\.itemEntity)
    private var item
    @Environment(ItemService.self)
    private var itemService

    @State private var isDialogPresented = false

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension DeleteItemButton: View {
    var body: some View {
        Button(role: .destructive) {
            Haptic.warning.impact()
            if let action {
                action()
            } else {
                isDialogPresented = true
            }
        } label: {
            Label {
                Text("Delete")
            } icon: {
                Image(systemName: "trash")
            }
        }
        .confirmationDialog(
            Text("Delete \(item.content)"),
            isPresented: $isDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    let model = try itemService.model(of: item)
                    try itemService.delete(items: [model])
                    Haptic.success.impact()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }
}

#Preview {
    IncomesPreview { preview in
        DeleteItemButton()
            .environment(ItemEntity(preview.items[.zero])!)
    }
}

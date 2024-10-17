//
//  DeleteItemButton 2.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/18/24.
//

import SwiftUI

struct DeleteItemButton {
    @Environment(Item.self)
    private var item
    @Environment(ItemService.self)
    private var itemService

    @State private var isPresented = false

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension DeleteItemButton: View {
    var body: some View {
        Button(role: .destructive) {
            if let action {
                action()
            } else {
                isPresented = true
            }
        } label: {
            Label {
                Text("Delete \(item.content)")
            } icon: {
                Image(systemName: "trash")
            }
        }
        .alert(Text("Delete \(item.content)"), isPresented: $isPresented) {
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
            Button(role: .destructive) {
                do {
                    try itemService.delete(items: [item])
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }
}

#Preview {
    IncomesPreview { preview in
        DeleteItemButton()
            .environment(preview.items[.zero])
    }
}

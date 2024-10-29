//
//  EditItemButton.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/18/24.
//

import SwiftUI

struct EditItemButton {
    @Environment(Item.self)
    private var item

    @State private var isPresented = false

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension EditItemButton: View {
    var body: some View {
        Button {
            if let action {
                action()
            } else {
                isPresented = true
            }
        } label: {
            Label {
                Text("Edit")
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .sheet(isPresented: $isPresented) {
            ItemFormNavigationView(mode: .edit)
        }
    }
}

#Preview {
    IncomesPreview { preview in
        EditItemButton()
            .environment(preview.items[.zero])
    }
}

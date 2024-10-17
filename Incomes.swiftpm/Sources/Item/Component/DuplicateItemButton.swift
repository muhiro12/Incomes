//
//  DuplicateItemButton.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/18/24.
//

import SwiftUI

struct DuplicateItemButton {
    @Environment(Item.self)
    private var item

    @State private var isPresented = false
}

extension DuplicateItemButton: View {
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label {
                Text("Duplicate \(item.content)")
            } icon: {
                Image(systemName: "document.on.document")
            }
        }
        .sheet(isPresented: $isPresented) {
            ItemFormNavigationView(mode: .create)
        }
    }
}

#Preview {
    IncomesPreview { preview in
        DuplicateItemButton()
            .environment(preview.items[.zero])
    }
}

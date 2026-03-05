//
//  EditItemButton.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/18/24.
//

import SwiftData
import SwiftUI

struct EditItemButton {
    @State private var isEditSheetPresented = false

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
                isEditSheetPresented = true
            }
        } label: {
            Label {
                Text("Edit")
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .sheet(isPresented: $isEditSheetPresented) {
            ItemFormNavigationView(mode: .edit)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    EditItemButton()
        .environment(items[.zero])
}

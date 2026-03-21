//
//  DuplicateItemButton.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/18/24.
//

import SwiftData
import SwiftUI

struct DuplicateItemButton {
    @State private var isDuplicateSheetPresented = false

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension DuplicateItemButton: View {
    var body: some View {
        Button {
            if let action {
                action()
            } else {
                isDuplicateSheetPresented = true
            }
        } label: {
            Label {
                Text("Duplicate")
            } icon: {
                Image(systemName: "document.on.document")
            }
        }
        .sheet(isPresented: $isDuplicateSheetPresented) {
            ItemFormNavigationView(mode: .create)
                .incomesSheetPresentation()
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    DuplicateItemButton()
        .environment(items[.zero])
}

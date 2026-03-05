//
//  ShowItemButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/02.
//

import SwiftData
import SwiftUI

struct ShowItemButton {
    @Environment(IncomesTipController.self)
    private var tipController

    @State private var isDetailSheetPresented = false

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension ShowItemButton: View {
    var body: some View {
        Button {
            tipController.donateDidOpenItemDetail()
            if let action {
                action()
            } else {
                isDetailSheetPresented = true
            }
        } label: {
            Label {
                Text("Show")
            } icon: {
                Image(systemName: "doc.text.magnifyingglass")
            }
        }
        .sheet(isPresented: $isDetailSheetPresented) {
            ItemNavigationView()
                .presentationDetents([.medium, .large])
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    ShowItemButton()
        .environment(items[.zero])
}

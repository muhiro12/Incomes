//
//  CreateItemButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//

import SwiftUI
import TipKit

struct CreateItemButton {
    @Environment(IncomesTipController.self)
    private var tipController

    @State private var isCreateSheetPresented = false

    private let createItemTip = CreateItemTip()
}

extension CreateItemButton: View {
    var body: some View {
        createButton
            .incomesProminentControlStyle()
            .popoverTip(createItemTip)
            .accessibilityLabel(Text("Create Item"))
            .accessibilityHint(Text("Opens the item form."))
            .sheet(isPresented: $isCreateSheetPresented) {
                ItemFormNavigationView(mode: .create)
                    .incomesSheetPresentation()
            }
    }
}

private extension CreateItemButton {
    var createButton: some View {
        Button {
            tipController.donateDidOpenCreateForm()
            isCreateSheetPresented = true
        } label: {
            Label {
                Text("Create")
            } icon: {
                Image(systemName: "square.and.pencil")
            }
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    CreateItemButton()
}

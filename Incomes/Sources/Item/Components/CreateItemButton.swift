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
        styledCreateButton
            .popoverTip(createItemTip)
            .sheet(isPresented: $isCreateSheetPresented) {
                ItemFormNavigationView(mode: .create)
                    .incomesSheetPresentation()
            }
    }
}

private extension CreateItemButton {
    @ViewBuilder var styledCreateButton: some View {
        if #available(iOS 26.0, *) {
            createButton
                .buttonStyle(.glassProminent)
        } else {
            createButton
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
        }
    }

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

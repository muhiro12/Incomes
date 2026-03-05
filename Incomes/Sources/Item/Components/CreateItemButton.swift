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
        .popoverTip(createItemTip)
        .sheet(isPresented: $isCreateSheetPresented) {
            ItemFormNavigationView(mode: .create)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    CreateItemButton()
}

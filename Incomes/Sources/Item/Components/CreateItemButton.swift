//
//  CreateItemButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//

import SwiftUI
import TipKit

struct CreateItemButton {
    enum Presentation {
        case contentAction
        case toolbar
    }

    @Environment(IncomesTipController.self)
    private var tipController

    @State private var isCreateSheetPresented = false

    private let presentation: Presentation
    private let createItemTip = CreateItemTip()

    init(presentation: Presentation = .contentAction) {
        self.presentation = presentation
    }
}

extension CreateItemButton: View {
    var body: some View {
        styledCreateButton
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
    @ViewBuilder var styledCreateButton: some View {
        switch presentation {
        case .contentAction:
            createButton
                .incomesProminentControlStyle()
        case .toolbar:
            createButton
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

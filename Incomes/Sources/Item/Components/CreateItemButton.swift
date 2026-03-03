//
//  CreateItemButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import TipKit

struct CreateItemButton {
    @Environment(IncomesTipController.self)
    private var tipController

    @StateObject private var router: CreateItemRouter = .init()

    private let createItemTip = CreateItemTip()
}

extension CreateItemButton: View {
    var body: some View {
        Button {
            tipController.donateDidOpenCreateForm()
            router.navigate(to: .create)
        } label: {
            Label {
                Text("Create")
            } icon: {
                Image(systemName: "square.and.pencil")
            }
        }
        .popoverTip(createItemTip)
        .sheet(item: $router.route) { _ in
            ItemFormNavigationView(mode: .create)
        }
    }
}

@MainActor
private final class CreateItemRouter: ObservableObject {
    @Published var route: CreateItemRoute?

    func navigate(to route: CreateItemRoute) {
        self.route = route
    }
}

private enum CreateItemRoute: String, Identifiable {
    case create

    var id: String {
        rawValue
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    CreateItemButton()
}

//
//  CreateItemButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct CreateItemButton {
    @StateObject private var router: CreateItemRouter = .init()
}

extension CreateItemButton: View {
    var body: some View {
        Button {
            router.navigate(to: .create)
        } label: {
            Label {
                Text("Create")
            } icon: {
                Image(systemName: "square.and.pencil")
            }
        }
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

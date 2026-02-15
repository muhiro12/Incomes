//
//  ShowItemButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/02.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ShowItemButton {
    @StateObject private var router: ShowItemRouter = .init()

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension ShowItemButton: View {
    var body: some View {
        Button {
            if let action {
                action()
            } else {
                router.navigate(to: .detail)
            }
        } label: {
            Label {
                Text("Show")
            } icon: {
                Image(systemName: "doc.text.magnifyingglass")
            }
        }
        .sheet(item: $router.route) { _ in
            ItemNavigationView()
                .presentationDetents([.medium, .large])
        }
    }
}

@MainActor
private final class ShowItemRouter: ObservableObject {
    @Published var route: ShowItemRoute?

    func navigate(to route: ShowItemRoute) {
        self.route = route
    }
}

private enum ShowItemRoute: String, Identifiable {
    case detail

    var id: String {
        rawValue
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    ShowItemButton()
        .environment(items[.zero])
}

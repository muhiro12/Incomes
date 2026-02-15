//
//  DuplicateItemButton.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/18/24.
//

import SwiftData
import SwiftUI

struct DuplicateItemButton {
    @StateObject private var router: DuplicateItemRouter = .init()

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
                router.navigate(to: .duplicate)
            }
        } label: {
            Label {
                Text("Duplicate")
            } icon: {
                Image(systemName: "document.on.document")
            }
        }
        .sheet(item: $router.route) { _ in
            ItemFormNavigationView(mode: .create)
        }
    }
}

@MainActor
private final class DuplicateItemRouter: ObservableObject {
    @Published var route: DuplicateItemRoute?

    func navigate(to route: DuplicateItemRoute) {
        self.route = route
    }
}

private enum DuplicateItemRoute: String, Identifiable {
    case duplicate

    var id: String {
        rawValue
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    DuplicateItemButton()
        .environment(items[.zero])
}

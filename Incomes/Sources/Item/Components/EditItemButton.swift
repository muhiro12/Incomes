//
//  EditItemButton.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/18/24.
//

import SwiftData
import SwiftUI

struct EditItemButton {
    @StateObject private var router: EditItemRouter = .init()

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension EditItemButton: View {
    var body: some View {
        Button {
            if let action {
                action()
            } else {
                router.navigate(to: .edit)
            }
        } label: {
            Label {
                Text("Edit")
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .sheet(item: $router.route) { _ in
            ItemFormNavigationView(mode: .edit)
        }
    }
}

@MainActor
private final class EditItemRouter: ObservableObject {
    @Published var route: EditItemRoute?

    func navigate(to route: EditItemRoute) {
        self.route = route
    }
}

private enum EditItemRoute: String, Identifiable {
    case edit

    var id: String {
        rawValue
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    EditItemButton()
        .environment(items[.zero])
}

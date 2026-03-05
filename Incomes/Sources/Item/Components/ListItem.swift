//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//

import SwiftData
import SwiftUI

struct ListItem: View {
    @Environment(Item.self)
    private var item // swiftlint:disable:this type_contents_order
    @Environment(\.modelContext)
    private var context // swiftlint:disable:this type_contents_order
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass // swiftlint:disable:this type_contents_order
    @Environment(IncomesTipController.self)
    private var tipController // swiftlint:disable:this type_contents_order

    @State private var detents = PresentationDetent.medium // swiftlint:disable:this type_contents_order
    @State private var isDeletePresented = false // swiftlint:disable:this type_contents_order
    @StateObject private var router: Router = .init() // swiftlint:disable:this type_contents_order

    var body: some View { // swiftlint:disable:this type_contents_order
        Button {
            detents = .medium
            tipController.donateDidOpenItemDetail()
            router.navigate(to: .detail)
        } label: {
            Group {
                if horizontalSizeClass == .regular {
                    WideListItem()
                } else {
                    NarrowListItem()
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .contextMenu {
            ShowItemButton {
                detents = .large
                router.navigate(to: .detail)
            }
            EditItemButton {
                router.navigate(to: .edit)
            }
            DuplicateItemButton {
                router.navigate(to: .duplicate)
            }
            RecalculateItemButton()
            DeleteItemButton {
                Haptic.warning.impact()
                isDeletePresented = true
            }
        } preview: {
            ItemPreviewNavigationView()
                .environment(item)
        }
        .sheet(item: $router.route) { route in
            buildSheet(for: route)
        }
        .confirmationDialog(
            Text("Delete \(item.content)"),
            isPresented: $isDeletePresented
        ) {
            Button(role: .destructive) {
                do {
                    try ItemService.delete(
                        context: context,
                        items: [item]
                    )
                    Haptic.success.impact()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }

    @MainActor
    private final class Router: ObservableObject {
        @Published var route: Route?

        func navigate(to route: Route) {
            self.route = route
        }
    }

    private enum Route: String, Identifiable {
        case detail
        case edit
        case duplicate

        var id: String {
            rawValue
        }
    }
}

private extension ListItem {
    @ViewBuilder
    private func buildSheet(for route: Route) -> some View {
        switch route {
        case .detail:
            ItemNavigationView()
                .presentationDetents(
                    [.medium, .large],
                    selection: $detents
                )
        case .edit:
            ItemFormNavigationView(mode: .edit)
        case .duplicate:
            ItemFormNavigationView(mode: .create)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        ListItem()
            .environment(items[0])
    }
}

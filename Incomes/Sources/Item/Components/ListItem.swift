//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ListItem: View {
    @Environment(Item.self)
    private var item
    @Environment(\.modelContext)
    private var context
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var detents = PresentationDetent.medium
    @StateObject private var router: ListItemRouter = .init()

    @State private var isDeletePresented = false

    var body: some View {
        Button {
            detents = .medium
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
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }
}

@MainActor
private final class ListItemRouter: ObservableObject {
    @Published var route: ListItemRoute?

    func navigate(to route: ListItemRoute) {
        self.route = route
    }
}

private extension ListItem {
    @ViewBuilder
    func buildSheet(for route: ListItemRoute) -> some View {
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

private enum ListItemRoute: String, Identifiable {
    case detail
    case edit
    case duplicate

    var id: String {
        rawValue
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

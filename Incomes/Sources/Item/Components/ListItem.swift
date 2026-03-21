//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//

import SwiftData
import SwiftUI
import TipKit

struct ListItem {
    @Environment(Item.self)
    private var item
    @Environment(\.modelContext)
    private var context
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @Environment(IncomesTipController.self)
    private var tipController

    @State private var detents = PresentationDetent.medium
    @State private var isDeletePresented = false
    @State private var route: Route?

    private let isItemDetailTipAnchor: Bool
    private let itemDetailTip = ItemDetailTip()

    init(isItemDetailTipAnchor: Bool = false) {
        self.isItemDetailTipAnchor = isItemDetailTipAnchor
    }
}

extension ListItem: View {
    var body: some View {
        if isItemDetailTipAnchor {
            button
                .popoverTip(itemDetailTip, arrowEdge: .top)
        } else {
            button
        }
    }
}

private extension ListItem {
    var button: some View {
        Button {
            detents = .medium
            tipController.donateDidOpenItemDetail()
            route = .detail
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
                route = .detail
            }
            EditItemButton {
                route = .edit
            }
            DuplicateItemButton {
                route = .duplicate
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
        .sheet(item: $route) { route in
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
}

private extension ListItem {
    enum Route: String, Identifiable {
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
                .incomesSheetPresentation()
        case .edit:
            ItemFormNavigationView(mode: .edit)
                .incomesSheetPresentation()
        case .duplicate:
            ItemFormNavigationView(mode: .create)
                .incomesSheetPresentation()
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        ListItem()
            .environment(items[0])
    }
}

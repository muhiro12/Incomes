//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItem: View {
    @Environment(ItemEntity.self)
    private var item
    @Environment(ItemService.self)
    private var itemService
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var detents = PresentationDetent.medium

    @State private var isDetailPresented = false
    @State private var isEditPresented = false
    @State private var isDuplicatePresented = false
    @State private var isDeletePresented = false

    var body: some View {
        Button {
            detents = .medium
            isDetailPresented = true
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
                isDetailPresented = true
            }
            EditItemButton {
                isEditPresented = true
            }
            DuplicateItemButton {
                isDuplicatePresented = true
            }
            DeleteItemButton {
                Haptic.warning.impact()
                isDeletePresented = true
            }
        } preview: {
            ItemNavigationView()
                .environment(item)
                .environment(itemService)
        }
        .sheet(isPresented: $isDetailPresented) {
            ItemNavigationView()
                .presentationDetents(
                    [.medium, .large],
                    selection: $detents
                )
        }
        .sheet(isPresented: $isEditPresented) {
            ItemFormNavigationView(mode: .edit)
        }
        .sheet(isPresented: $isDuplicatePresented) {
            ItemFormNavigationView(mode: .create)
        }
        .confirmationDialog(
            Text("Delete \(item.content)"),
            isPresented: $isDeletePresented
        ) {
            Button(role: .destructive) {
                do {
                    let model = try itemService.model(of: item)
                    try itemService.delete(items: [model])
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

#Preview {
    IncomesPreview { preview in
        List {
            ListItem()
                .environment(ItemEntity(preview.items[0])!)
        }
    }
}

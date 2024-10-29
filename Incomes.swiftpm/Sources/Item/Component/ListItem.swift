//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItem: View {
    @Environment(Item.self)
    private var item
    @Environment(ItemService.self)
    private var itemService
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var isDetailPresented = false
    @State private var isEditPresented = false
    @State private var isDuplicatePresented = false
    @State private var isDeletePresented = false

    var body: some View {
        Button {
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
            EditItemButton {
                isEditPresented = true
            }
            DuplicateItemButton {
                isDuplicatePresented = true
            }
            DeleteItemButton {
                isDeletePresented = true
            }
        }
        .sheet(isPresented: $isDetailPresented) {
            ItemNavigationView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isEditPresented) {
            ItemFormNavigationView(mode: .edit)
        }
        .sheet(isPresented: $isDuplicatePresented) {
            ItemFormNavigationView(mode: .create)
        }
        .confirmationDialog(Text("Delete \(item.content)"), isPresented: $isDeletePresented) {
            Button(role: .destructive) {
                do {
                    try itemService.delete(items: [item])
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
                .environment(preview.items[0])
        }
    }
}

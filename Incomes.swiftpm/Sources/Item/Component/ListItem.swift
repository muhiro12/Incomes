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
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var isEditPresented = false

    var body: some View {
        Button {
            isEditPresented = true
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
        .sheet(isPresented: $isEditPresented) {
            ItemFormNavigationView(mode: .edit(item))
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    IncomesPreview { preview in
        ListItem()
            .environment(preview.items[0])
    }
}

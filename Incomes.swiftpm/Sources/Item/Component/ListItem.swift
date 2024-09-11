//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItem: View {
    @Environment(Item.self) private var item

    @State private var isEditPresented = false

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width < .portraitModeMaxWidth {
                NarrowListItem()
            } else {
                WideListItem()
            }
        }
        .sheet(isPresented: $isEditPresented) {
            ItemFormNavigationView(mode: .edit(item))
                .presentationDetents([.medium, .large])
        }
        .contentShape(.rect)
        .onTapGesture {
            isEditPresented = true
        }
    }
}

#Preview {
    IncomesPreview { preview in
        ListItem()
            .environment(preview.items[0])
    }
}

//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItem {
    @State private var isEditPresented = false

    private let item: Item

    init(of item: Item) {
        self.item = item
    }
}

extension ListItem: View {
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width < .portraitModeMaxWidth {
                NarrowListItem(of: item)
            } else {
                WideListItem(of: item)
            }
        }
        .sheet(isPresented: $isEditPresented) {
            ItemFormNavigationView(mode: .edit, item: item)
                .presentationDetents([.medium, .large])
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isEditPresented = true
        }
    }
}

#Preview {
    ListItem(of: PreviewData.items[0])
}

//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItem {
    @Environment(\.modelContext)
    private var context

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
            NavigationStack {
                ItemFormView(mode: .edit, item: item)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isEditPresented = true
        }
    }
}

#Preview {
    ModelPreview {
        ListItem(of: $0)
    }
}

#Preview(traits: .landscapeLeft) {
    ModelPreview {
        ListItem(of: $0)
    }
}

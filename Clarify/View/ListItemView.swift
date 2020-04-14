//
//  ListItemView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItemView: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresented = false

    private let item: ListItem

    init(of item: ListItem) {
        self.item = item
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 500 {
                ListItemWideView(of: self.item)
            } else {
                ListItemNarrowView(of: self.item)
            }
        }.sheet(isPresented: $isPresented) {
            ItemEditView(of: self.item)
                .environment(\.managedObjectContext, self.context)
        }.onTapGesture {
            self.isPresented = true
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(of:
            ListItem(id: UUID(),
                     date: Date(),
                     content: "Content",
                     income: 999999,
                     expenditure: 99999,
                     balance: 9999999)
        )
    }
}

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

    let item: ListItem

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 500 {
                ListItemWideView(item: self.item)
            } else {
                ListItemNarrowView(item: self.item)
            }
        }.sheet(isPresented: self.$isPresented) {
            ItemEditView(listItem: self.item)
                .environment(\.managedObjectContext, self.context)
        }.onTapGesture {
            self.isPresented = true
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(item: ListItem(date: Date(),
                                    content: "Content",
                                    income: 999999,
                                    expenditure: 99999,
                                    balance: 9999999))
    }
}

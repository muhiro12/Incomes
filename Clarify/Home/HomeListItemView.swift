//
//  HomeListItemView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListItemView: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresented = false

    let item: HomeListItem

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 500 {
                HomeListItemWideView(item: self.item)
            } else {
                HomeListItemNarrowView(item: self.item)
            }
        }.sheet(isPresented: self.$isPresented) {
            ItemCreateView(listItem: self.item)
                .environment(\.managedObjectContext, self.context)
        }.onTapGesture {
            self.isPresented = true
        }
    }
}

struct HomeListItemView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListItemView(item: HomeListItem(date: Date(),
                                            content: "Content",
                                            income: 999999,
                                            expenditure: 99999,
                                            balance: 9999999))
    }
}

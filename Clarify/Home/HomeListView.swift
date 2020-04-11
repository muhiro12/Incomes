//
//  HomeListView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListView: View {
    @Environment(\.managedObjectContext) var context

    let listItems: [HomeListItem]

    var body: some View {
        List {
            ForEach(listItems) { listItem in
                HomeListItemView(item: listItem)
            }.onDelete(perform: delete)
        }
    }

    private func delete(indexSet: IndexSet) {
        indexSet.forEach {
            if let item = listItems[$0].item {
                context.delete(item)
            }
        }
    }
}

struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListView(listItems: [
            HomeListItem(date: Date(),
                         content: "Content",
                         income: 999999,
                         expenditure: 99999,
                         balance: 9999999)
        ])
    }
}

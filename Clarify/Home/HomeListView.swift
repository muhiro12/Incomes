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
            ForEach(listItems) {
                HomeListItemView(item: $0.item, sum: $0.balance)
            }.onDelete(perform: delete)
        }
    }

    private func delete(indexSet: IndexSet) {
        indexSet.forEach {
            context.delete(listItems[$0].item)
        }
    }
}

struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListView(listItems: [])
    }
}

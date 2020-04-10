//
//  HomeListView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListView: View {
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: true)]
    ) var items: FetchedResults<Item>

    var body: some View {
        List {
            ForEach(createListItem().reversed()) { item in
                HomeListItemView(item: item.item, sum: item.balance)
            }.onDelete(perform: delete)
        }
    }

    private func delete(indexSet: IndexSet) {
        print("delete")
    }

    private func createListItem() -> [HomeListItem] {
        var listItem: [HomeListItem] = []
        for index in 0..<items.count {
            let item = items[index]

            var balance = 0
            if listItem.count > 0 {
                balance += listItem[index - 1].balance
            }
            balance += Int(item.income + item.expenditure)

            listItem.append(HomeListItem(item: item, balance: balance))
        }
        return listItem
    }
}

struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListView()
    }
}

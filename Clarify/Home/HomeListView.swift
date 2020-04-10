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
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: false)]
    ) var items: FetchedResults<Item>

    var body: some View {
        List {
            ForEach(items) { item in
                HomeListItemView(item: item, sum: self.sumUp(item: item))
            }.onDelete(perform: delete)
        }
    }

    private func delete(indexSet: IndexSet) {
        print("delete")
    }

    private func sumUp(item: Item) -> Int {
        var sum = 0
        for index in (items.firstIndex(of: item) ?? 0).advanced(by: 0)..<items.count {
            sum += Int(items[index].income + items[index].expenditure)
        }
        return sum
    }
}

struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListView()
    }
}

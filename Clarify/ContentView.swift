//
//  ContentView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: true)]
    ) var items: FetchedResults<Item>

    var body: some View {
        TabsManageView(items: listItems)
    }

    private var listItems: ListItems {
        var listItems = ListItems(value: [])
        for index in 0..<items.count {
            let item = items[index]

            var balance = 0
            if listItems.value.count > 0 {
                balance += listItems.value[index - 1].balance
            }
            balance += Int(item.income - item.expenditure)

            if let date = item.date,
                let content = item.content {
                let listItem = ListItem(original: item,
                                        date: date,
                                        content: content,
                                        income: Int(item.income),
                                        expenditure: Int(item.expenditure),
                                        balance: balance)
                listItems.value.append(listItem)
            }
        }
        return listItems
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  HomeView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var context

    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: true)]
    ) var items: FetchedResults<Item>

    @State private var isPresented = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationView {
                Form {
                    ForEach(
                        createListItemsArray(
                            from: createListItems(
                                from: items.map { $0 }
                            ).value.reversed()
                        )
                    ) { listItems in
                        NavigationLink(destination:
                            ListView(listItems: listItems.value)
                                .navigationBarTitle(listItems.key ?? "")) {
                                    Text(listItems.key ?? "")
                        }
                    }
                }.navigationBarTitle("Clarify")
            }
            FloatingCircleButtonView {
                self.isPresented = true
            }
        }.sheet(isPresented: self.$isPresented) {
            ItemEditView()
                .environment(\.managedObjectContext, self.context)
        }
    }

    private func createListItems(from items: [Item]) -> ListItems {
        var listItemArray: [ListItem] = []
        for index in 0..<items.count {
            let item = items[index]

            var balance = 0
            if listItemArray.count > 0 {
                balance += listItemArray[index - 1].balance
            }
            balance += Int(item.income + item.expenditure)

            if let date = item.date,
                let content = item.content {
                let listItem = ListItem(original: item,
                                        date: date,
                                        content: content,
                                        income: Int(item.income),
                                        expenditure: Int(item.expenditure),
                                        balance: balance)
                listItemArray.append(listItem)
            }
        }
        return ListItems(value: listItemArray)
    }

    private func createListItemsArray(from listItemArray: [ListItem]) -> [ListItems] {
        var listItemsArray: [ListItems] = []

        let groupedDictionary = Dictionary(grouping: listItemArray) { listItem -> String in
            return listItem.date.yyyyMM
        }.sorted {
            $0.key > $1.key
        }
        groupedDictionary.forEach {
            let items = ListItems(key: $0.key, value: $0.value)
            listItemsArray.append(items)
        }
        return listItemsArray
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

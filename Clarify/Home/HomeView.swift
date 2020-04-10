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
                        groupByYear(
                            listItems: createListItems(
                                from: items.map { $0 }
                            ).reversed()
                        )
                    ) { listItemsPerYear in
                        NavigationLink(destination:
                            HomeListView(listItems: listItemsPerYear.listItems)
                                .navigationBarTitle(listItemsPerYear.year)) {
                                    Text(listItemsPerYear.year)
                        }
                    }
                }.navigationBarTitle("Clarify")
            }
            FloatingCircleButtonView {
                self.isPresented = true
            }
        }.sheet(isPresented: self.$isPresented) {
            ItemCreateView()
                .environment(\.managedObjectContext, self.context)
        }
    }

    private func groupByYear(listItems: [HomeListItem]) -> [HomeListItemsPerYear] {
        var listItemsPerYears: [HomeListItemsPerYear] = []

        let dictionary = Dictionary(grouping: listItems) { listItem -> String in
            return DateConverter().convertToMonth(listItem.date)
        }.sorted {
            $0.key > $1.key
        }
        dictionary.forEach {
            let items = HomeListItemsPerYear(year: $0.key, listItems: $0.value)
            listItemsPerYears.append(items)
        }
        return listItemsPerYears
    }

    private func createListItems(from items: [Item]) -> [HomeListItem] {
        var listItems: [HomeListItem] = []
        for index in 0..<items.count {
            let item = items[index]

            var balance = 0
            if listItems.count > 0 {
                balance += listItems[index - 1].balance
            }
            balance += Int(item.income + item.expenditure)

            if let date = item.date,
                let content = item.content {
                let listItem = HomeListItem(item: item,
                                            date: date,
                                            content: content,
                                            income: Int(item.income),
                                            expenditure: Int(item.expenditure),
                                            balance: balance)
                listItems.append(listItem)
            }
        }
        return listItems
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

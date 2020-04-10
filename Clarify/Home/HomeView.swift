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
        NavigationView {
            Form {
                ForEach(
                    groupByYear(
                        listItems: createListItems(
                            from: items.map { $0 }
                        ).reversed()
                    )
                ) { temp in
                    NavigationLink(destination:
                        ZStack(alignment: .bottomTrailing) {
                            HomeListView(listItems: temp.listItems)
                            FloatingCircleButtonView {
                                self.isPresented = true
                            }
                        }.sheet(isPresented: self.$isPresented) {
                            CreateView()
                                .environment(\.managedObjectContext, self.context)
                        }.navigationBarTitle(temp.year)) {
                            Text(temp.year)
                    }
                }
            }.navigationBarTitle("Clarify")
        }
    }

    private func groupByYear(listItems: [HomeListItem]) -> [HomeListItemsPerYear] {
        var temps: [HomeListItemsPerYear] = []

        let dict = Dictionary(grouping: listItems) { listItem -> String in
            guard let date = listItem.item.date else {
                return ""
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }.sorted {
            $0.key > $1.key
        }
        dict.forEach {
            let temp = HomeListItemsPerYear(year: $0.key, listItems: $0.value)
            temps.append(temp)
        }
        return temps
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

            listItems.append(HomeListItem(item: item, balance: balance))
        }
        return listItems
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

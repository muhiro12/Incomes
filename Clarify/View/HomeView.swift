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

    @State private var isPresented = false

    let title: String
    let items: ListItems
    // TODO: Temp
    var isHome = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationView {
                Form {
                    ForEach(createListItemsArray(from: items)) { items in
                        NavigationLink(destination:
                            ListView(of: items)
                                .navigationBarTitle(items.key ?? "")) {
                                    Text(items.key ?? "")
                        }
                    }
                }.navigationBarTitle(title)
            }
            FloatingCircleButtonView {
                self.isPresented = true
            }
        }.sheet(isPresented: self.$isPresented) {
            ItemEditView()
                .environment(\.managedObjectContext, self.context)
        }
    }

    private func createListItemsArray(from items: ListItems?) -> [ListItems] {
        guard let items = items else {
            return []
        }

        var listItemsArray: [ListItems] = []

        let groupedDictionary = Dictionary(grouping: items.value) { item -> String in
            // TODO: Temp
            if isHome {
                return item.date.yyyyMM
            } else {
                return item.original?.group?.uuidString ?? ""
            }
        }.sorted {
            $0.key > $1.key
        }
        groupedDictionary.forEach {
            listItemsArray.append(
                // TODO: Temp
                ListItems(key: (isHome ? $0.key : $0.value.last?.content),
                          value: $0.value)
            )
        }

        return listItemsArray
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(title: "Home",
                 items: ListItems(value: [
                    ListItem(date: Date(),
                             content: "Content",
                             income: 999999,
                             expenditure: 99999,
                             balance: 9999999)
                 ])
        )
    }
}

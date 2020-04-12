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

    var items: ListItems?
    // TODO: Temp
    var isHome = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationView {
                Form {
                    ForEach(createListItemsArray(from: items?.value.reversed())) { listItems in
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

    private func createListItemsArray(from listItemArray: [ListItem]?) -> [ListItems] {
        guard let listItemArray = listItemArray else {
            return []
        }

        var listItemsArray: [ListItems] = []

        let groupedDictionary = Dictionary(grouping: listItemArray) { listItem -> String in
            // TODO: Temp
            if isHome {
                return listItem.date.yyyyMM
            } else {
                return listItem.original?.group?.uuidString ?? ""
            }
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
        HomeView(items: nil)
    }
}

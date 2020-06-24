//
//  ListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresentedToAlert = false
    @State private var indexSet = IndexSet()

    private let items: ListItems

    init(of items: ListItems) {
        self.items = items
    }

    var body: some View {
        List {
            ForEach(items.value) { item in
                ListItemView(of: item)
            }.onDelete(perform: presentToAlert)
        }.selectedListStyle()
            .alert(isPresented: $isPresentedToAlert) {
                Alert(title: Text(verbatim: .caution),
                      message: Text(verbatim: .cautionDetail),
                      primaryButton: .destructive(Text(verbatim: .delete),
                                                  action: delete),
                      secondaryButton: .cancel())
        }
    }

    private func presentToAlert(indexSet: IndexSet) {
        self.indexSet = indexSet
        isPresentedToAlert = true
    }

    private func delete() {
        indexSet.forEach {
            if let item = items.value[$0].original {
                let dataStore = DataStore(context: context)
                dataStore.delete(item)
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(of:
            ListItems(key: "All",
                      value: [
                        ListItem(id: UUID(),
                                 date: Date(),
                                 content: "Content",
                                 income: 999999,
                                 expenditure: 99999,
                                 balance: 9999999,
                                 group: .empty,
                                 repeatId: UUID())
            ])
        )
    }
}

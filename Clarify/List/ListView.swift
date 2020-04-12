//
//  ListView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @Environment(\.managedObjectContext) var context

    let listItems: [ListItem]

    var body: some View {
        List {
            ForEach(listItems) { listItem in
                ListItemView(item: listItem)
            }.onDelete(perform: delete)
        }
    }

    private func delete(indexSet: IndexSet) {
        indexSet.forEach {
            if let item = listItems[$0].original {
                context.delete(item)
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(listItems: [
            ListItem(date: Date(),
                     content: "Content",
                     income: 999999,
                     expenditure: 99999,
                     balance: 9999999)
        ])
    }
}

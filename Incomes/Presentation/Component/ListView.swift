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

    private let items: [Item]

    init(of items: [Item]) {
        self.items = items
    }

    var body: some View {
        List {
            ForEach(items) { item in
                ListItemView(of: item)
            }.onDelete(perform: presentToAlert)
        }.selectedListStyle()
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(title: Text(.localized(.deleteConfirm)),
                        buttons: [
                            .destructive(Text(.localized(.delete)),
                                         action: delete),
                            .cancel()
                        ])
        }
    }
}

// MARK: - private

private extension ListView {
    func presentToAlert(indexSet: IndexSet) {
        self.indexSet = indexSet
        isPresentedToAlert = true
    }

    func delete() {
        indexSet.forEach {
            Repository.delete(context, item: items[$0])
        }
    }
}

#if DEBUG
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(of: PreviewData.listItems)
    }
}
#endif

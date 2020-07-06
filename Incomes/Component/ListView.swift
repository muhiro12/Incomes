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
                Alert(title: Text(LocalizableStrings.caution.localized),
                      message: Text(LocalizableStrings.cautionDetail.localized),
                      primaryButton: .destructive(Text(LocalizableStrings.delete.localized),
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
            Repository.delete(context, item: items.value[$0])
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

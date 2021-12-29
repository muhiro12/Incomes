//
//  ItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ItemListView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest private var items: FetchedResults<Item>

    @State private var isPresentedToAlert = false
    @State private var indexSet = IndexSet()

    private let title: String

    init(title: String, predicate: NSPredicate) {
        self.title = title
        _items = FetchRequest<Item>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: false)],
            predicate: predicate,
            animation: .default)
    }

    var body: some View {
        List {
            ForEach(items) {
                ListItem(of: $0)
            }.onDelete {
                self.indexSet = $0
                isPresentedToAlert = true
            }
        }.selectedListStyle()
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(title: Text(.localized(.deleteConfirm)),
                        buttons: [
                            .destructive(Text(.localized(.delete))) {
                                indexSet.forEach {
                                    Repository.delete(viewContext, item: items[$0])
                                }
                            },
                            .cancel()])
        }.navigationBarTitle(title)
    }
}

#if DEBUG
struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(title: "Title",
                     predicate: .init(dateBetweenMonthFor: Date()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif

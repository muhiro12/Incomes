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

    @SectionedFetchRequest
    private var sections: SectionedFetchResults<String, Item>

    @State
    private var isPresentedToAlert = false
    @State
    private var indexSet = IndexSet()

    private let title: String

    init(title: String, predicate: NSPredicate) {
        self.title = title
        _sections = .init(
            sectionIdentifier: \Item.year,
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: false)],
            predicate: predicate,
            animation: .default)
    }

    var body: some View {
        List {
            ForEach(sections) { section in
                Section(content: {
                    ForEach(section) {
                        ListItem(of: $0)
                    }
                }, header: {
                    if sections.count > .one {
                        Text(section.id)
                    }
                })
            }.onDelete {
                self.indexSet = $0
                isPresentedToAlert = true
            }
        }.actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(title: Text(.localized(.deleteConfirm)),
                        buttons: [
                            .destructive(Text(.localized(.delete))) {
                                // TODO: Delete item
                            },
                            .cancel()])
        }.navigationBarTitle(title)
    }
}

#if DEBUG
struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(title: "Title",
                     predicate: .init(dateIsSameMonthAs: Date()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif

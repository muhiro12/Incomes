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
    private var sections: SectionedFetchResults<Date, Item>

    @State
    private var isPresentedToAlert = false
    @State
    private var willDeleteItems: [Item] = []

    private let title: String

    init(title: String, predicate: NSPredicate) {
        self.title = title
        _sections = .init(
            sectionIdentifier: \Item.startOfYear,
            sortDescriptors: NSSortDescriptor.standards,
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
                    .onDelete {
                        willDeleteItems = $0.map { section[$0] }
                        isPresentedToAlert = true
                    }
                }, header: {
                    if sections.count > .one {
                        Text(section.id.stringValue(.yyyy))
                    }
                })
                Advertisement(type: .native(.small))
            }
        }
        .id(UUID())
        .navigationBarTitle(title)
        .listStyle(.grouped)
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(title: Text(.localized(.deleteConfirm)),
                        buttons: [
                            .destructive(Text(.localized(.delete))) {
                                do {
                                    try ItemService(context: viewContext).delete(items: willDeleteItems)
                                } catch {
                                    assertionFailure(error.localizedDescription)
                                }
                            },
                            .cancel {
                                willDeleteItems = []
                            }])
        }
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

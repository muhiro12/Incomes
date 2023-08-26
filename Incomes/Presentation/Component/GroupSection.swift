//
//  GroupSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GroupSection: View {
    typealias Element = (content: String, items: [Item])

    @Environment(\.managedObjectContext)
    var viewContext

    @State
    private var isPresentedToAlert = false
    @State
    private var willDeleteItems: [Item] = []

    private let title: String
    private let elements: [Element]

    init(title: String, items: [Item]) {
        self.title = title
        self.elements = ItemService.groupByContent(items: items)
    }

    var body: some View {
        Section(content: {
            ForEach(elements.indices) { index in
                NavigationLink(elements[index].content) {
                    ItemListView(title: elements[index].content,
                                 predicate: .init(contentIs: elements[index].content))
                }
            }.onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { elements[$0].items }
            }
        }, header: {
            Text(title)
        }).actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(
                title: Text(.localized(.deleteConfirm)),
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
                    }
                ])
            }
    }
}

#if DEBUG
struct GroupSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            GroupSection(title: "Credit",
                         items: PreviewData().items.filter {
                            $0.group == "Credit"
                         })
        }
    }
}
#endif

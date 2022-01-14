//
//  YearSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct YearSection: View {
    typealias Element = (month: Date, items: [Item])

    @Environment(\.managedObjectContext)
    private var viewContext

    @State
    private var isPresentedToAlert = false
    @State
    private var willDeleteItems: [Item] = []

    private let year: Date
    private let elements: [Element]

    init(year: Date, items: [Item]) {
        self.year = year
        self.elements = ItemService.groupByMonth(items: items)
    }

    var body: some View {
        Section(content: {
            ForEach(0..<elements.count) { index in
                NavigationLink(elements[index].month.stringValue(.yyyyMMM)) {
                    ItemListView(title: elements[index].month.stringValue(.yyyyMMM),
                                 predicate: .init(dateIsSameMonthAs: elements[index].month))
                }
            }.onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { elements[$0].items }
            }
        }, header: {
            Text(year.stringValue(.yyyy))
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
                    }])
        }
    }
}

#if DEBUG
struct YearSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            YearSection(year: Date(),
                        items: PreviewData().items.filter {
                            $0.year.stringValue(.yyyy) == "2022"
                        })
        }
    }
}
#endif

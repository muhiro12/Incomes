//
//  YearSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct YearSection: View {
    @Environment(\.modelContext)
    private var context

    @State
    private var isPresentedToAlert = false
    @State
    private var willDeleteItems: [Item] = []

    private let startOfYear: Date
    private let sections: [SectionedItems<Date>]

    init(startOfYear: Date, items: [Item]) {
        self.startOfYear = startOfYear
        self.sections = ItemService.groupByMonth(items: items)
    }

    var body: some View {
        Section(content: {
            ForEach(0..<sections.count, id: \.self) { index in
                NavigationLink(sections[index].section.stringValue(.yyyyMMM)) {
                    ItemListView(title: sections[index].section.stringValue(.yyyyMMM),
                                 predicate: Item.predicate(dateIsSameMonthAs: sections[index].section))
                }
            }.onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { sections[$0].items }
            }
        }, header: {
            Text(startOfYear.stringValue(.yyyy))
        }).actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(
                title: Text(.localized(.deleteConfirm)),
                buttons: [
                    .destructive(Text(.localized(.delete))) {
                        do {
                            try ItemService(context: context).delete(items: willDeleteItems)
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

#Preview {
    List {
        YearSection(startOfYear: Date(),
                    items: PreviewSampleData.items.filter {
                        $0.date.stringValue(.yyyy) == "2023"
                    })
    }
}

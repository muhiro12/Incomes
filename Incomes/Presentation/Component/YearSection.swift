//
//  YearSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct YearSection {
    @Environment(\.modelContext)
    private var context

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let startOfYear: Date
    private let sections: [SectionedItems<Date>]

    init(startOfYear: Date, items: [Item]) {
        self.startOfYear = startOfYear
        self.sections = ItemService.groupByMonth(items: items)
    }
}

extension YearSection: View {
    var body: some View {
        Section(content: {
            ForEach(0..<sections.count, id: \.self) { index in
                NavigationLink(sections[index].section.stringValue(.yyyyMMM), value: sections[index])
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
                    items: PreviewData.items.filter {
                        $0.date.stringValue(.yyyy) == "2023"
                    })
    }
}

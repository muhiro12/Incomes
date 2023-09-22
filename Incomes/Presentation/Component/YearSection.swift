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

    private let year: String
    private let sections: [SectionedItems<Date>]

    init(year: String, items: [Item]) {
        self.year = year
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
            Text(year)
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
    ModelsPreview { items in
        List {
            YearSection(
                year: "2023",
                items: items.filter {
                    $0.date.stringValue(.yyyy) == "2023"
                }
            )
        }
    }
}

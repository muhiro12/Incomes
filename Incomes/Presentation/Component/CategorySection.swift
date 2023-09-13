//
//  CategorySection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct CategorySection {
    @Environment(\.modelContext)
    private var context

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let title: String
    private let sections: [SectionedItems<String>]

    init(title: String, items: [Item]) {
        self.title = title
        self.sections = ItemService.groupByContent(items: items)
    }
}

extension CategorySection: View {
    var body: some View {
        Section(content: {
            ForEach(sections.indices, id: \.self) { index in
                NavigationLink(sections[index].section, value: sections[index])
            }.onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { sections[$0].items }
            }
        }, header: {
            Text(title)
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
        CategorySection(
            title: "Credit",
            items: PreviewData.items.filter {
                $0.group == "Credit"
            }
        )
    }
}

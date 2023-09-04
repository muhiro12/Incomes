//
//  GroupView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct GroupView {
    @Query(filter: Item.predicate(groupIsNot: .empty))
    private var groupingItems: [Item]

    @Query(filter: Item.predicate(groupIs: .empty), sort: \.group)
    private var othersItems: [Item]
}

extension GroupView: View {
    var body: some View {
        List {
            ForEach(groupingSections) {
                GroupSection(title: $0.section, items: $0.items)
            }
            if !othersItems.isEmpty {
                GroupSection(title: .localized(.others), items: othersItems)
            }
        }
        .id(UUID())
        .listStyle(.sidebar)
        .navigationBarTitle(.localized(.groupTitle))
    }
}

private extension GroupView {
    var groupingSections: [SectionedItems<String>] {
        ItemService.groupByGroup(items: groupingItems)
    }
}

#Preview {
    GroupView()
        .modelContainer(PreviewData.inMemoryContainer)
}

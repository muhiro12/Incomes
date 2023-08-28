//
//  GroupView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct GroupView: View {
    @Query(filter: Item.predicate(groupIsNot: .empty))
    private var groupingItems: [Item]
    private var groupingSections: [SectionedItems<String>] {
        ItemService.groupByGroup(items: groupingItems)
    }

    @Query(filter: Item.predicate(groupIs: .empty), sort: \.group)
    private var othersItems: [Item]

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

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        GroupView()
    }
}

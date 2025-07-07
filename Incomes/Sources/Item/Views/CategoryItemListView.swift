//
//  CategoryItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/07/09.
//

import SwiftData
import SwiftUI

struct CategoryItemListView {
    @Environment(TagEntity.self)
    private var tag
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
}

extension CategoryItemListView: View {
    var body: some View {
        List(yearStrings, id: \.self) { yearString in
            TagItemListSection(yearString: yearString)
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
        }
        .listStyle(.grouped)
        .navigationTitle(Text(tag.displayName))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                ToolbarAlignmentSpacer()
            }
            ToolbarItem(placement: .status) {
                Text("\(items.count) Items")
                    .font(.footnote)
            }
            ToolbarItem(placement: .bottomBar) {
                CreateItemButton()
            }
        }
    }
}

private extension CategoryItemListView {
    var items: [ItemEntity] {
        (
            try? tag.model(in: context).items.orEmpty.compactMap(ItemEntity.init)
        ).orEmpty
    }

    var yearStrings: [String] {
        Set(
            items.compactMap {
                $0.date.stringValueWithoutLocale(.yyyy)
            }
        ).sorted(by: >)
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            CategoryItemListView()
                .environment(
                    preview.tags.first { $0.type == .category }!
                )
        }
    }
}

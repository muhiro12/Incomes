//
//  CategoryItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/07/09.
//

import MHPlatform
import SwiftData
import SwiftUI

struct CategoryItemListView {
    @Environment(Tag.self)
    private var tag
    @Environment(IncomesTipController.self)
    private var tipController

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn
}

extension CategoryItemListView: View {
    var body: some View {
        List(Array(yearStrings.enumerated()), id: \.element) { index, yearString in
            TagItemListSection(
                yearString: yearString,
                showsItemDetailTip: index == .zero
            )
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
        }
        .listStyle(.grouped)
        .navigationTitle(tag.displayName)
        .task(id: items.count) {
            guard items.isNotEmpty else {
                return
            }
            tipController.donateDidViewItemList()
        }
        .toolbar {
            StatusToolbarItem("\(items.count) Items")
        }
        .toolbar {
            SpacerToolbarItem(placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                CreateItemButton()
            }
        }
    }
}

private extension CategoryItemListView {
    var items: [Item] {
        TagService.items(for: tag)
    }

    var yearStrings: [String] {
        TagService.yearStrings(for: tag)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        if let tag = tags.first(where: { previewTag in
            previewTag.type == .category
        }) {
            CategoryItemListView()
                .environment(tag)
        }
    }
}

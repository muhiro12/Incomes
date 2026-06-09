//
//  ContentItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/07/09.
//

import MHPlatform
import SwiftData
import SwiftUI

struct ContentItemListView {
    @Environment(Tag.self)
    private var tag
    @Environment(IncomesTipController.self)
    private var tipController

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn
}

extension ContentItemListView: View {
    var body: some View {
        List(Array(yearStrings.enumerated()), id: \.element) { index, yearString in
            ItemListSection(
                .items(.tagAndYear(tag: tag, yearString: yearString)),
                title: .init(
                    yearString
                        .dateValueWithoutLocale(.yyyy)?
                        .stringValue(.yyyy) ?? .empty
                ),
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

private extension ContentItemListView {
    var items: [Item] {
        tag.items.orEmpty
    }

    var yearStrings: [String] {
        TagOperations.yearStrings(for: tag)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        if let tag = tags.first(where: { previewTag in
            previewTag.type == .content
        }) {
            ContentItemListView()
                .environment(tag)
        }
    }
}

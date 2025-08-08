//
//  ContentItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/07/09.
//

import SwiftData
import SwiftUI

struct ContentItemListView {
    @Environment(Tag.self)
    private var tag

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
}

extension ContentItemListView: View {
    var body: some View {
        List(yearStrings, id: \.self) { yearString in
            ItemListSection(
                .items(.tagAndYear(tag: tag, yearString: yearString)),
                title: .init(
                    yearString
                        .dateValueWithoutLocale(.yyyy)?
                        .stringValue(.yyyy) ?? .empty
                )
            )
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

private extension ContentItemListView {
    var items: [ItemEntity] {
        tag.items.orEmpty.compactMap(ItemEntity.init)
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
            if let tag = preview.tags.first(where: { $0.type == .content }) {
                ContentItemListView()
                    .environment(tag)
            }
        }
    }
}

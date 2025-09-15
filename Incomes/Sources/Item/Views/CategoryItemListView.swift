//
//  CategoryItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/07/09.
//

import SwiftData
import SwiftUI

struct CategoryItemListView {
    @Environment(Tag.self)
    private var tag

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
            ToolbarAlignmentSpacer(placement: .bottomBar)
            StatusToolbarItem("\(items.count) Items")
            ToolbarItem(placement: .bottomBar) {
                CreateItemButton()
            }
        }
    }
}

private extension CategoryItemListView {
    var items: [Item] {
        tag.items.orEmpty
    }

    var yearStrings: [String] {
        Set(
            items.map {
                $0.localDate.stringValueWithoutLocale(.yyyy)
            }
        ).sorted(by: >)
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            if let tag = preview.tags.first(where: { $0.type == .category }) {
                CategoryItemListView()
                    .environment(tag)
            }
        }
    }
}

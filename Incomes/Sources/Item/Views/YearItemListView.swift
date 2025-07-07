//
//  YearItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/07/09.
//

import SwiftData
import SwiftUI

struct YearItemListView {
    @Environment(TagEntity.self)
    private var tag
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
}

extension YearItemListView: View {
    var body: some View {
        List(yearStrings, id: \.\self) { yearString in
            ItemListSection(
                .items(.tagAndYear(tag: tag, yearString: yearString))
            )
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
            ChartSectionGroup(
                .items(.tagAndYear(tag: tag, yearString: yearString))
            )
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

private extension YearItemListView {
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
            YearItemListView()
                .environment(
                    preview.tags.first { $0.type == .year }!
                )
        }
    }
}

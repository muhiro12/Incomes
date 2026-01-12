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
        .navigationTitle(tag.displayName)
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
        tag.items.orEmpty
    }

    var yearStrings: [String] {
        TagService.yearStrings(for: tag)
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            if let tag = preview.tags.first(where: { previewTag in
                previewTag.type == .category
            }) {
                CategoryItemListView()
                    .environment(tag)
            }
        }
    }
}

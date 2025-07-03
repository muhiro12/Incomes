//
//  ItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ItemListView {
    @Environment(TagEntity.self)
    private var tag
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
}

extension ItemListView: View {
    var body: some View {
        List(yearStrings, id: \.self) { yearString in
            switch tag.type {
            case .year,
                 .yearMonth,
                 .content:
                ItemListSection(
                    .items(.tagAndYear(tag: tag, yearString: yearString)),
                    title: tag.type == .content
                        ? .init(yearString.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? .empty)
                        : nil
                )
            case .category:
                TagItemListSection(yearString: yearString)
            case .none:
                EmptyView()
            }
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
            switch tag.type {
            case .year,
                 .yearMonth:
                ChartSectionGroup(.items(.tagAndYear(tag: tag, yearString: yearString)))
            case .content,
                 .category,
                 .none:
                EmptyView()
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

private extension ItemListView {
    @MainActor
    var items: [ItemEntity] {
        (
            try? tag.model(in: context).items.orEmpty.compactMap(ItemEntity.init)
        ).orEmpty
    }

    @MainActor
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
            ItemListView()
                .environment(
                    preview.tags.first {
                        $0.type == .year
                    }
                )
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            ItemListView()
                .environment(
                    preview.tags.first {
                        $0.type == .yearMonth
                    }
                )
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            ItemListView()
                .environment(
                    preview.tags.first {
                        $0.type == .content
                    }
                )
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            ItemListView()
                .environment(
                    preview.tags.first {
                        $0.type == .category
                    }
                )
        }
    }
}

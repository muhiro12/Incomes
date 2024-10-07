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
    @Environment(Tag.self)
    private var tag

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
}

extension ItemListView: View {
    var body: some View {
        List(yearStrings, id: \.self) { yearString in
            ItemListSection(
                .items(.tagAndYear(tag: tag, yearString: yearString)),
                title: {
                    switch tag.type {
                    case .year,
                         .yearMonth:
                        nil
                    case .content,
                         .category,
                         .none:
                        .init(yearString.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? .empty)
                    }
                }()
            )
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
            ChartSections(.items(.tagAndYear(tag: tag, yearString: yearString)))
        }
        .listStyle(.grouped)
        .navigationTitle(Text(tag.displayName))
        .toolbar {
            ToolbarItem {
                CreateButton()
            }
            ToolbarItem(placement: .status) {
                Text("\(tag.items.orEmpty.count) Items")
                    .font(.footnote)
            }
        }
    }
}

private extension ItemListView {
    var yearStrings: [String] {
        Set(
            tag.items.orEmpty.compactMap {
                $0.year?.name
            }
        ).sorted(by: >)
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            ItemListView()
                .environment(preview.tags.first { $0.type == .year })
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            ItemListView()
                .environment(preview.tags.first { $0.type == .yearMonth })
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            ItemListView()
                .environment(preview.tags.first { $0.type == .content })
        }
    }
}

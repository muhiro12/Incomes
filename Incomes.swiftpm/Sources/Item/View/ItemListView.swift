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
    private var isSubscribeOn: Bool

    @State private var years = [String]()
}

extension ItemListView: View {
    var body: some View {
        List(years, id: \.self) { year in
            ItemListSection(descriptor(year))
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
            switch tag.type {
            case .year,
                 .yearMonth:
                ChartSections(descriptor(year))
            case .content,
                 .category,
                 .none:
                EmptyView()
            }
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
        .task {
            years = Set(
                tag.items?.compactMap {
                    $0.year?.name
                } ?? .empty
            ).sorted(by: >)
        }
    }
}

private extension ItemListView {
    func descriptor(_ year: String) -> FetchDescriptor<Item> {
        switch tag.type {
        case .year:
            if let date = tag.name.dateValueWithoutLocale(.yyyy) {
                return .items(.dateIsSameYearAs(date))
            }
        case .yearMonth:
            if let date = tag.name.dateValueWithoutLocale(.yyyyMM) {
                return .items(.dateIsSameMonthAs(date))
            }
        case .content:
            return .items(.contentAndYear(content: tag.name, year: year))
        case .category:
            break
        case .none:
            break
        }
        return .items(.none)
    }
}

#Preview {
    IncomesPreview { preview in
        ItemListView()
            .environment(preview.tags.first { $0.name == Date.now.stringValueWithoutLocale(.yyyy) }!)
    }
}

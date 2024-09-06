//
//  ItemListYearSections.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/23.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ItemListYearSections {
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    @Query private var items: [Item]

    private let yearTag: Tag
    private let descriptor: Item.FetchDescriptor

    init(yearTag: Tag, descriptor: Item.FetchDescriptor) {
        self.yearTag = yearTag
        self.descriptor = descriptor
        _items = Query(descriptor)
    }
}

extension ItemListYearSections: View {
    var body: some View {
        Group {
            ItemListSection(title: yearTag.displayName, descriptor: descriptor)
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
            ChartSections(items: items)
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            ItemListYearSections(
                yearTag: preview.tags.first { $0.type == .year }!,
                descriptor: Item.descriptor(dateIsSameMonthAs: .now)
            )
        }
    }
}

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
    private var isSubscribeOn: Bool

    private let descriptor: FetchDescriptor<Item>

    init(_ descriptor: FetchDescriptor<Item>) {
        self.descriptor = descriptor
    }
}

extension ItemListYearSections: View {
    var body: some View {
        Group {
            ItemListSection(descriptor)
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
            ChartSections(descriptor)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            ItemListYearSections(Item.descriptor(.dateIsSameMonthAs(.now)))
        }
    }
}

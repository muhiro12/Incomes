//
//  ChartSectionGroup.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/06/03.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import Charts
import SwiftData
import SwiftUI

struct ChartSectionGroup {
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private let descriptor: FetchDescriptor<Item>

    init(_ descriptor: FetchDescriptor<Item>) {
        self.descriptor = descriptor
    }
}

extension ChartSectionGroup: View {
    var body: some View {
        BalanceChartSection(descriptor)
        IncomeAndOutgoChartSection(descriptor)
        if !isSubscribeOn {
            AdvertisementSection(.medium)
        }
        CategoryChartSection(descriptor)
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            ChartSectionGroup(.items(.dateIsSameYearAs(.now)))
        }
    }
}

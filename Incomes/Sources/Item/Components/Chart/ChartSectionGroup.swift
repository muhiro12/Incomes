//
//  ChartSectionGroup.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/06/03.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ChartSectionGroup {
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private let descriptor: FetchDescriptor<Item>
    private let yearScopedDate: Date?

    init(_ descriptor: FetchDescriptor<Item>) {
        self.descriptor = descriptor
        self.yearScopedDate = nil
    }

    init(yearScopedTo date: Date) {
        self.descriptor = .items(.none)
        self.yearScopedDate = date
    }
}

extension ChartSectionGroup: View {
    var body: some View {
        BalanceChartSection(descriptor)
        IncomeAndOutgoChartSection(descriptor)
        if !isSubscribeOn {
            AdvertisementSection(.medium)
        }
        if let date = yearScopedDate {
            CategoryChartSection(yearScopedTo: date)
        } else {
            CategoryChartSection(descriptor)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            ChartSectionGroup(.items(.dateIsSameYearAs(.now)))
        }
    }
}

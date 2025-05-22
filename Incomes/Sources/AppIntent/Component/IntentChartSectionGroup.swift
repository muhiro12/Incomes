//
//  IntentChartSectionGroup.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct IntentChartSectionGroup {
    private let descriptor: FetchDescriptor<Item>

    init(_ descriptor: FetchDescriptor<Item>) {
        self.descriptor = descriptor
    }
}

extension IntentChartSectionGroup: View {
    var body: some View {
        BalanceChartSection(descriptor)
        IncomeAndOutgoChartSection(descriptor)
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

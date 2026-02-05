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
        Group {
            BalanceChartSection(descriptor)
            IncomeAndOutgoChartSection(descriptor)
            CategoryChartSection(descriptor)
        }
        .safeAreaPadding()
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    IntentChartSectionGroup(
        .items(
            .idsAre(
                items.prefix(10).map(\.id)
            )
        )
    )
}

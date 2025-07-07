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

#Preview {
    IncomesPreview { preview in
        IntentChartSectionGroup(
            .items(
                .idsAre(
                    preview.items.prefix(10).compactMap { idEntity in
                        try? PersistentIdentifier(base64Encoded: idEntity.id)
                    }
                )
            )
        )
    }
}

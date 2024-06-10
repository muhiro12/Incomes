//
//  ChartSections.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/06/03.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import Charts
import SwiftUI

struct ChartSections {
    private let items: [Item]

    init(items: [Item]) {
        self.items = items
    }
}

extension ChartSections: View {
    var body: some View {
        Section("Balance") {
            Chart(items) {
                buildChartContent(date: $0.date,
                                  value: $0.balance)
            }
            .frame(height: .componentL)
            .padding()
        }
        Section("Income and Outgo") {
            Chart(items) {
                buildChartContent(date: $0.date,
                                  value: $0.income)
                buildChartContent(date: $0.date,
                                  value: $0.outgo * -1)
            }
            .frame(height: .componentL)
            .padding()
        }
    }
}

private extension ChartSections {
    @ChartContentBuilder
    func buildChartContent(date: Date, value: Decimal) -> some ChartContent {
        if value != .zero {
            BarMark(x: .value("Date", date),
                    y: .value("Amount", value),
                    stacking: .unstacked)
                .foregroundStyle(value.isPlus ? Color.accentColor : Color.red)
                .opacity(.medium)
            RectangleMark(x: .value("Date", date),
                          y: .value("Amount", value))
                .foregroundStyle(value.isPlus ? Color.accentColor : Color.red)
        }
    }
}

#Preview {
    ChartSections(items: [])
}

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
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private let items: [Item]

    init(items: [Item]) {
        self.items = items.sorted()
    }
}

extension ChartSections: View {
    var body: some View {
        Section("Balance") {
            Chart(items) {
                buildAreaChartContent(date: $0.date,
                                      value: $0.balance)
                buildBarChartContent(date: $0.date,
                                     value: $0.balance)
            }
            .frame(height: .componentL)
            .padding()
        }
        Section("Income and Outgo") {
            Chart(items) {
                buildBarChartContent(date: $0.date,
                                     value: $0.income)
                buildBarChartContent(date: $0.date,
                                     value: $0.outgo * -1)
            }
            .frame(height: .componentL)
            .padding()
        }
        if !isSubscribeOn {
            AdvertisementSection(.medium)
        }
        Section("Category") {
            Chart(
                Array(
                    Dictionary(
                        grouping: items.filter {
                            $0.isProfitable
                        }
                    ) {
                        guard let category = $0.category,
                              category.displayName.isNotEmpty else {
                            return "Others"
                        }
                        return category.displayName
                    }
                ),
                id: \.key
            ) {
                buildSectorChartContent(title: $0.key, items: $0.value)
            }
            .chartForegroundStyleScale { (title: String) in
                Color.accentColor.adjusted(with: title.hashValue)
            }
            .frame(height: .componentXL)
            .padding()
            Chart(
                Array(
                    Dictionary(
                        grouping: items.filter {
                            !$0.isProfitable
                        }
                    ) {
                        guard let category = $0.category,
                              category.displayName.isNotEmpty else {
                            return "Others"
                        }
                        return category.displayName
                    }
                ),
                id: \.key
            ) {
                buildSectorChartContent(title: $0.key, items: $0.value)
            }
            .chartForegroundStyleScale { (title: String) in
                Color.red.adjusted(with: title.hashValue)
            }
            .frame(height: .componentXL)
            .padding()
        }
    }
}

private extension ChartSections {
    @ChartContentBuilder
    func buildAreaChartContent(date: Date, value: Decimal) -> some ChartContent {
        AreaMark(
            x: .value("Date", date),
            y: .value("Amount", value),
            stacking: .unstacked
        )
        .opacity(.medium)
        LineMark(
            x: .value("Date", date),
            y: .value("Amount", value)
        )
        .opacity(.medium)
    }

    @ChartContentBuilder
    func buildBarChartContent(date: Date, value: Decimal) -> some ChartContent {
        BarMark(
            x: .value("Date", date),
            y: .value("Amount", value),
            stacking: .unstacked
        )
        .foregroundStyle(value.isPlus ? Color.accentColor : Color.red)
        .opacity(.medium)
        RectangleMark(
            x: .value("Date", date),
            y: .value("Amount", value)
        )
        .foregroundStyle(value.isPlus ? Color.accentColor : Color.red)
    }

    @ChartContentBuilder
    func buildSectorChartContent(title: String, items: [Item]) -> some ChartContent {
        let value = abs(items.reduce(0) { $0 + $1.profit })
        SectorMark(
            angle: .value(title, value),
            innerRadius: .ratio(0.618),
            outerRadius: .inset(10),
            angularInset: 1
        )
        .cornerRadius(4)
        .foregroundStyle(by: .value("Category", "\(title): \(value.asCurrency)"))
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            ChartSections(items: Array(preview.items.prefix(upTo: 20)))
        }
    }
}

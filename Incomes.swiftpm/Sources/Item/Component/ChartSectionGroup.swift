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

    @Query private var items: [Item]

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = .init(descriptor)
    }
}

extension ChartSectionGroup: View {
    var body: some View {
        Section {
            Chart(items) {
                buildAreaChartContent(date: $0.date,
                                      value: $0.balance)
                buildBarChartContent(date: $0.date,
                                     value: $0.balance)
            }
            .frame(height: .componentL)
            .padding()
        } header: {
            Text("Balance")
        }
        Section {
            Chart(items) {
                buildBarChartContent(date: $0.date,
                                     value: $0.income)
                buildBarChartContent(date: $0.date,
                                     value: $0.outgo * -1)
            }
            .frame(height: .componentL)
            .padding()
        } header: {
            Text("Income and Outgo")
        }
        if !isSubscribeOn {
            AdvertisementSection(.medium)
        }
        Section {
            Chart(
                Dictionary(
                    grouping: items.filter(\.income.isNotZero)
                ) {
                    guard let category = $0.category else {
                        return "Others"
                    }
                    return category.displayName
                }.map { displayName, items in
                    (title: displayName, value: items.reduce(.zero) { $0 + $1.income })
                }.sorted {
                    $0.value > $1.value
                },
                id: \.title
            ) {
                buildSectorChartContent(title: $0.title, value: $0.value)
            }
            .chartForegroundStyleScale { (title: String) in
                Color(uiColor: .tintColor).adjusted(with: title.hashValue)
            }
            .frame(height: .componentXL)
            .padding()
            Chart(
                Dictionary(
                    grouping: items.filter(\.outgo.isNotZero)
                ) {
                    guard let category = $0.category else {
                        return "Others"
                    }
                    return category.displayName
                }.map { displayName, items in
                    (title: displayName, value: items.reduce(.zero) { $0 + $1.outgo })
                }.sorted {
                    $0.value > $1.value
                },
                id: \.title
            ) {
                buildSectorChartContent(title: $0.title, value: $0.value)
            }
            .chartForegroundStyleScale { (title: String) in
                Color.red.adjusted(with: title.hashValue)
            }
            .frame(height: .componentXL)
            .padding()
        } header: {
            Text("Category")
        }
    }
}

private extension ChartSectionGroup {
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
        if value.isNotZero {
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
    }

    @ChartContentBuilder
    func buildSectorChartContent(title: String, value: Decimal) -> some ChartContent {
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
    IncomesPreview { _ in
        List {
            ChartSectionGroup(.items(.dateIsSameYearAs(.now)))
        }
    }
}

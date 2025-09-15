//
//  CategoryChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import SwiftData
import SwiftUI

struct CategoryChartSection: View {
    @Query private var items: [Item]

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = .init(descriptor)
    }

    private var incomeObjects: [(title: String, value: Decimal)] {
        let filtered: [Item] = items.filter(\.income.isNotZero)
        let grouped: [String: [Item]] = .init(grouping: filtered) { item in
            item.category?.displayName ?? "Others"
        }
        return grouped.map { displayName, items in
            (
                title: displayName,
                value: items.reduce(.zero) { result, item in
                    result + item.income
                }
            )
        }
        .sorted { left, right in
            left.value > right.value
        }
    }

    private var outgoObjects: [(title: String, value: Decimal)] {
        let filtered: [Item] = items.filter(\.outgo.isNotZero)
        let grouped: [String: [Item]] = .init(grouping: filtered) { item in
            item.category?.displayName ?? "Others"
        }
        return grouped.map { displayName, items in
            (
                title: displayName,
                value: items.reduce(.zero) { result, item in
                    result + item.outgo
                }
            )
        }
        .sorted { left, right in
            left.value > right.value
        }
    }

    var body: some View {
        Section {
            Chart(incomeObjects, id: \.title) { object in
                SectorMark(
                    angle: .value(
                        object.title,
                        NSDecimalNumber(decimal: object.value).doubleValue
                    ),
                    innerRadius: .ratio(0.618),
                    outerRadius: .inset(10),
                    angularInset: 1
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Category", "\(object.title): \(object.value.asCurrency)"))
            }
            .chartForegroundStyleScale { (title: String) in
                .accent.adjusted(by: title.hashValue)
            }
            .frame(height: .componentXL)
            .padding()
            Chart(outgoObjects, id: \.title) { object in
                SectorMark(
                    angle: .value(
                        object.title,
                        NSDecimalNumber(decimal: object.value).doubleValue
                    ),
                    innerRadius: .ratio(0.618),
                    outerRadius: .inset(10),
                    angularInset: 1
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Category", "\(object.title): \(object.value.asCurrency)"))
            }
            .chartForegroundStyleScale { (title: String) in
                .red.adjusted(by: title.hashValue)
            }
            .frame(height: .componentXL)
            .padding()
        } header: {
            Text("Category")
        }
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            CategoryChartSection(.items(.dateIsSameYearAs(.now)))
        }
    }
}

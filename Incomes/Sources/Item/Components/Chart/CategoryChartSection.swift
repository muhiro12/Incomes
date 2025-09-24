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
    // Legacy single-source query (kept for compatibility)
    @Query private var items: [Item]
    // New: split sources to express non-zero income/outgo at fetch-time
    @Query private var incomeItems: [Item]
    @Query private var outgoItems: [Item]

    private let useSeparatedQueries: Bool

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = .init(descriptor)
        // Unused queries initialized with the same descriptor to satisfy property wrapper
        _incomeItems = .init(descriptor)
        _outgoItems = .init(descriptor)
        useSeparatedQueries = false
    }

    init(yearScopedTo date: Date) {
        // Income: year scope + income non-zero
        var incomeQuery = ItemQuery()
        incomeQuery.date = .sameYear(date)
        incomeQuery.incomeNonZero = true
        _incomeItems = .init(incomeQuery.descriptor())

        // Outgo: year scope + outgo non-zero
        var outgoQuery = ItemQuery()
        outgoQuery.date = .sameYear(date)
        outgoQuery.outgoNonZero = true
        _outgoItems = .init(outgoQuery.descriptor())

        // Legacy items not used in this mode
        _items = .init(.items(.none))
        useSeparatedQueries = true
    }

    private var incomeObjects: [(title: String, value: Decimal)] {
        let source: [Item] = useSeparatedQueries ? incomeItems : items.filter(\.income.isNotZero)
        let grouped: [String: [Item]] = .init(grouping: source) { item in
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
        let source: [Item] = useSeparatedQueries ? outgoItems : items.filter(\.outgo.isNotZero)
        let grouped: [String: [Item]] = .init(grouping: source) { item in
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
            .frame(height: .component(.xl))
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
            .frame(height: .component(.xl))
            .padding()
        } header: {
            Text("Category")
        }
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            CategoryChartSection(yearScopedTo: .now)
        }
    }
}

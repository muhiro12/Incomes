//
//  CategoryChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import SwiftData
import SwiftUI

struct CategoryChartSection {
    @Query private var items: [Item]

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = .init(descriptor)
    }
}

extension CategoryChartSection: View {
    var body: some View {
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
                    (
                        title: displayName,
                        value: items.reduce(.zero) { $0 + $1.income }
                    )
                }.sorted {
                    $0.value > $1.value
                },
                id: \.title
            ) { object in
                SectorMark(
                    angle: .value(object.title, object.value),
                    innerRadius: .ratio(0.618),
                    outerRadius: .inset(10),
                    angularInset: 1
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Category", "\(object.title): \(object.value.asCurrency)"))
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
                    (
                        title: displayName,
                        value: items.reduce(.zero) { $0 + $1.outgo }
                    )
                }.sorted {
                    $0.value > $1.value
                },
                id: \.title
            ) { object in
                SectorMark(
                    angle: .value(object.title, object.value),
                    innerRadius: .ratio(0.618),
                    outerRadius: .inset(10),
                    angularInset: 1
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Category", "\(object.title): \(object.value.asCurrency)"))
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

#Preview {
    IncomesPreview { _ in
        List {
            CategoryChartSection(.items(.dateIsSameYearAs(.now)))
        }
    }
}

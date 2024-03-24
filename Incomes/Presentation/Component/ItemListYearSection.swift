//
//  ItemListYearSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/23.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Charts
import SwiftData
import SwiftUI

struct ItemListYearSection {
    @Environment(\.modelContext)
    private var context

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @Query private var items: [Item]

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let title: String

    init(yearTag: Tag, predicate: Predicate<Item>) {
        title = yearTag.displayName
        _items = Query(filter: predicate, sort: Item.sortDescriptors())
    }
}

extension ItemListYearSection: View {
    // TODO: Resolve SwiftLint and remove static Strings
    var body: some View {
        Group { // swiftlint:disable:this closure_body_length
            Section(content: {
                ForEach(items) {
                    ListItem(of: $0)
                }
                .onDelete {
                    willDeleteItems = $0.map { items[$0] }
                    isPresentedToAlert = true
                }
            }, header: {
                Text(title)
            })
            if isSubscribeOn {
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
            } else {
                Section {
                    Advertisement(type: .native(.medium))
                }
            }
        }
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(title: Text("Are you sure you want to delete this item?"),
                        buttons: [
                            .destructive(Text("Delete")) {
                                do {
                                    try ItemService(context: context).delete(items: willDeleteItems)
                                } catch {
                                    assertionFailure(error.localizedDescription)
                                }
                            },
                            .cancel {
                                willDeleteItems = []
                            }
                        ])
        }
    }
}

private extension ItemListYearSection {
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
    ItemListYearSection(
        yearTag: PreviewData.tags.filter {
            $0.type == .year
        }[0],
        predicate: Item.predicate(dateIsSameMonthAs: .now)
    )
    .previewList()
    .previewContext()
}

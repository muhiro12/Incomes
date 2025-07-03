//
//  IncomeAndOutgoChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import SwiftData
import SwiftUI
import SwiftUtilities

struct IncomeAndOutgoChartSection: View {
    @BridgeQuery private var items: [ItemEntity]

    @State private var isPresented = false

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = .init(descriptor)
    }

    var body: some View {
        Section {
            Button {
                isPresented = true
            } label: {
                chart()
                    .frame(height: .componentL)
                    .padding()
            }
            .fullScreenCover(isPresented: $isPresented) {
                NavigationStack {
                    chart()
                        .chartScrollableAxes(.horizontal)
                        .chartScrollPosition(initialX: Date.now)
                        .padding()
                        .navigationTitle(Text("Income and Outgo"))
                        .toolbar {
                            ToolbarItem {
                                CloseButton()
                            }
                        }
                }
            }
        } header: {
            Text("Income and Outgo")
        }
    }
}

private extension IncomeAndOutgoChartSection {
    func chart() -> some View {
        Chart(items) { item in
            if income(of: item).isNotZero {
                BarMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", income(of: item)),
                    stacking: .unstacked
                )
                .foregroundStyle(income(of: item).isPlus ? Color.accentColor : Color.red)
                .opacity(.medium)
                RectangleMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", income(of: item))
                )
                .foregroundStyle(income(of: item).isPlus ? Color.accentColor : Color.red)
            }
            if outgo(of: item).isNotZero {
                BarMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", outgo(of: item)),
                    stacking: .unstacked
                )
                .foregroundStyle(outgo(of: item).isPlus ? Color.accentColor : Color.red)
                .opacity(.medium)
                RectangleMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", outgo(of: item))
                )
                .foregroundStyle(outgo(of: item).isPlus ? Color.accentColor : Color.red)
            }
        }
    }

    func date(of item: ItemEntity) -> Date {
        Calendar.current.shiftedDate(
            componentsFrom: item.date,
            in: .utc
        )
    }

    func income(of item: ItemEntity) -> Decimal {
        item.income
    }

    func outgo(of item: ItemEntity) -> Decimal {
        item.outgo * -1
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            IncomeAndOutgoChartSection(.items(.dateIsSameYearAs(.now)))
        }
    }
}

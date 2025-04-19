//
//  IncomeAndOutgoChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import SwiftData
import SwiftUI

struct IncomeAndOutgoChartSection {
    @Query private var items: [Item]

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = .init(descriptor)
    }
}

extension IncomeAndOutgoChartSection: View {
    var body: some View {
        Section {
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
            .frame(height: .componentL)
            .padding()
        } header: {
            Text("Income and Outgo")
        }
    }
}

private extension IncomeAndOutgoChartSection {
    func date(of item: Item) -> Date {
        item.date
    }

    func income(of item: Item) -> Decimal {
        item.income
    }

    func outgo(of item: Item) -> Decimal {
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

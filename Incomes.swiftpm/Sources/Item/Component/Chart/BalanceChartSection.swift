//
//  BalanceChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import SwiftData
import SwiftUI

struct BalanceChartSection {
    @Query private var items: [Item]

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = .init(descriptor)
    }
}

extension BalanceChartSection: View {
    var body: some View {
        Section {
            Chart(items) { item in
                AreaMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", balance(of: item)),
                    stacking: .unstacked
                )
                .opacity(.medium)
                LineMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", balance(of: item))
                )
                .opacity(.medium)
                if balance(of: item).isNotZero {
                    BarMark(
                        x: .value("Date", date(of: item)),
                        y: .value("Amount", balance(of: item)),
                        stacking: .unstacked
                    )
                    .foregroundStyle(balance(of: item).isPlus ? Color.accentColor : Color.red)
                    .opacity(.medium)
                    RectangleMark(
                        x: .value("Date", date(of: item)),
                        y: .value("Amount", balance(of: item))
                    )
                    .foregroundStyle(balance(of: item).isPlus ? Color.accentColor : Color.red)
                }
            }
            .frame(height: .componentL)
            .padding()
        } header: {
            Text("Balance")
        }
    }
}

private extension BalanceChartSection {
    func date(of item: Item) -> Date {
        item.date
    }

    func balance(of item: Item) -> Decimal {
        item.balance
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            BalanceChartSection(.items(.dateIsSameYearAs(.now)))
        }
    }
}

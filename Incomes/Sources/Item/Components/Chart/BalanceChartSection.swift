//
//  BalanceChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import SwiftData
import SwiftUI
import SwiftUtilities

struct BalanceChartSection: View {
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
                        .navigationTitle(Text("Balance"))
                        .toolbar {
                            ToolbarItem {
                                CloseButton()
                            }
                        }
                }
            }
        } header: {
            Text("Balance")
        }
    }
}

private extension BalanceChartSection {
    func chart() -> some View {
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
    }

    func date(of item: ItemEntity) -> Date {
        Calendar.current.shiftedDate(
            componentsFrom: item.date,
            in: .utc
        )
    }

    func balance(of item: ItemEntity) -> Decimal {
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

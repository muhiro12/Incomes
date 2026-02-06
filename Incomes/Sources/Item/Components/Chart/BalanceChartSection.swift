//
//  BalanceChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import SwiftData
import SwiftUI

struct BalanceChartSection: View {
    @Query private var items: [Item]

    @State private var isPresented = false

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = Query(descriptor)
    }

    var body: some View {
        Section {
            Button {
                isPresented = true
            } label: {
                chart()
                    .frame(height: .component(.l))
                    .padding()
            }
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $isPresented) {
                NavigationStack {
                    chart()
                        .chartScrollableAxes(.horizontal)
                        .chartScrollPosition(initialX: Date.now)
                        .padding()
                        .navigationTitle("Balance")
                        .navigationBarTitleDisplayMode(.inline)
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
        Chart {
            RuleMark(y: .value("Zero", 0))
                .foregroundStyle(.secondary.opacity(0.25))
                .lineStyle(.init(lineWidth: 1, dash: [4]))

            ForEach(items) { item in
                AreaMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", balance(of: item)),
                    stacking: .unstacked
                )
                .foregroundStyle(.tint)
                .interpolationMethod(.catmullRom)
                .opacity(0.2)
                LineMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", balance(of: item))
                )
                .foregroundStyle(.tint)
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: 2))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 3)) { _ in
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(0.2))
                AxisTick()
                    .foregroundStyle(.secondary.opacity(0.4))
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { _ in
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(0.2))
                AxisTick()
                    .foregroundStyle(.secondary.opacity(0.4))
                AxisValueLabel()
            }
        }
    }

    func date(of item: Item) -> Date {
        item.localDate
    }

    func balance(of item: Item) -> Decimal {
        item.balance
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        BalanceChartSection(.items(.dateIsSameYearAs(.now)))
    }
}

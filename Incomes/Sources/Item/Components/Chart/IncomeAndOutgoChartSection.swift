//
//  IncomeAndOutgoChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import SwiftData
import SwiftUI

struct IncomeAndOutgoChartSection: View {
    @Query private var items: [Item]

    @StateObject private var router: IncomeAndOutgoChartRouter = .init()

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = Query(descriptor)
    }

    var body: some View {
        Section {
            Button {
                router.navigate(to: .detail)
            } label: {
                chart()
                    .frame(height: .component(.l))
                    .padding()
            }
            .buttonStyle(.plain)
            .fullScreenCover(item: $router.route) { _ in
                NavigationStack {
                    chart()
                        .chartScrollableAxes(.horizontal)
                        .chartScrollPosition(initialX: Date.now)
                        .padding()
                        .navigationTitle("Income and Outgo")
                        .navigationBarTitleDisplayMode(.inline)
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

@MainActor
private final class IncomeAndOutgoChartRouter: ObservableObject {
    @Published var route: IncomeAndOutgoChartRoute?

    func navigate(to route: IncomeAndOutgoChartRoute) {
        self.route = route
    }
}

private enum IncomeAndOutgoChartRoute: String, Identifiable {
    case detail

    var id: String {
        rawValue
    }
}

private extension IncomeAndOutgoChartSection {
    func chart() -> some View {
        Chart {
            RuleMark(y: .value("Zero", 0))
                .foregroundStyle(.secondary.opacity(0.25))
                .lineStyle(.init(lineWidth: 1, dash: [4]))

            ForEach(items) { item in
                if income(of: item).isNotZero {
                    BarMark(
                        x: .value("Date", date(of: item)),
                        y: .value("Amount", income(of: item)),
                        stacking: .unstacked
                    )
                    .foregroundStyle(.green)
                    .opacity(0.6)
                }
                if outgo(of: item).isNotZero {
                    BarMark(
                        x: .value("Date", date(of: item)),
                        y: .value("Amount", outgo(of: item)),
                        stacking: .unstacked
                    )
                    .foregroundStyle(.red)
                    .opacity(0.6)
                }
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

    func income(of item: Item) -> Decimal {
        item.income
    }

    func outgo(of item: Item) -> Decimal {
        item.outgo * -1
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        IncomeAndOutgoChartSection(.items(.dateIsSameYearAs(.now)))
    }
}

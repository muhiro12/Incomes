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
    @Query private var items: [Item] // swiftlint:disable:this type_contents_order

    @StateObject private var router: Router = .init() // swiftlint:disable:this type_contents_order

    var body: some View { // swiftlint:disable:this type_contents_order
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

    init(_ descriptor: FetchDescriptor<Item>) { // swiftlint:disable:this type_contents_order
        _items = Query(descriptor)
    }

    @MainActor
    private final class Router: ObservableObject {
        @Published var route: Route?

        func navigate(to route: Route) {
            self.route = route
        }
    }

    private enum Route: String, Identifiable {
        case detail

        var id: String {
            rawValue
        }
    }
}

private extension BalanceChartSection {
    private enum Constants {
        static let zeroRuleYValue: Double = .zero
        static let zeroRuleOpacity = 0.25
        static let zeroRuleLineWidth: CGFloat = 1
        static let zeroRuleDashLength: CGFloat = 4
        static let areaMarkOpacity = 0.2
        static let lineMarkWidth: CGFloat = 2
        static let xAxisMonthStride = 3
        static let axisGridOpacity = 0.2
        static let axisTickOpacity = 0.4
    }

    func chart() -> some View {
        Chart {
            RuleMark(y: .value("Zero", Constants.zeroRuleYValue))
                .foregroundStyle(.secondary.opacity(Constants.zeroRuleOpacity))
                .lineStyle(
                    .init(
                        lineWidth: Constants.zeroRuleLineWidth,
                        dash: [Constants.zeroRuleDashLength]
                    )
                )

            ForEach(items) { item in
                AreaMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", balance(of: item)),
                    stacking: .unstacked
                )
                .foregroundStyle(.tint)
                .interpolationMethod(.catmullRom)
                .opacity(Constants.areaMarkOpacity)
                LineMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", balance(of: item))
                )
                .foregroundStyle(.tint)
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: Constants.lineMarkWidth))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: Constants.xAxisMonthStride)) { _ in
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(Constants.axisGridOpacity))
                AxisTick()
                    .foregroundStyle(.secondary.opacity(Constants.axisTickOpacity))
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { _ in
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(Constants.axisGridOpacity))
                AxisTick()
                    .foregroundStyle(.secondary.opacity(Constants.axisTickOpacity))
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

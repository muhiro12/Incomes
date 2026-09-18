import Charts
import SwiftUI

/// Chart section comparing current and projected monthly balances.
struct ItemFormBalanceProjectionChartSection: View {
    private enum Metrics {
        static let chartHeight: CGFloat = 220
        static let currentLineWidth: CGFloat = 2
        static let projectedLineWidth: CGFloat = 3
        static let legendSpacing: CGFloat = 2
        static let zeroRuleDashLength: CGFloat = 4
        static let zeroRuleLineWidth: CGFloat = 1
        static let zeroRuleOpacity = 0.35
    }

    @Environment(\.locale)
    private var locale

    let comparison: ItemBalanceProjectionOperations.Comparison

    var body: some View {
        Section {
            Chart {
                zeroRuleMark()
                currentBalanceMarks()
                projectedBalanceMarks()
            }
            .frame(height: Metrics.chartHeight)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Balance projection chart"))
            .accessibilityValue(chartAccessibilityValue)

            ViewThatFits(in: .horizontal) {
                HStack {
                    currentLegendLabel
                    Spacer()
                    projectedLegendLabel
                }
                VStack(alignment: .leading, spacing: Metrics.legendSpacing) {
                    currentLegendLabel
                    projectedLegendLabel
                }
            }
            .font(.caption)
        }
    }
}

private extension ItemFormBalanceProjectionChartSection {
    var currentLegendLabel: some View {
        Label("Current", systemImage: "minus")
            .foregroundStyle(.secondary)
    }

    var projectedLegendLabel: some View {
        Label("Projected", systemImage: "minus")
            .foregroundStyle(.tint)
    }

    var chartAccessibilityValue: Text {
        Text(
            verbatim: chartAccessibilityValueParts
                .formatted(.list(type: .and).locale(locale))
        )
    }

    var chartAccessibilityValueParts: [String] {
        let projectedBalance = comparison.projected.latestBalance?
            .currencyText(locale: locale) ?? "-"
        let difference = comparison.latestBalanceDifference.map { difference in
            ItemFormBalanceProjectionFormatting.signedCurrencyText(
                difference,
                locale: locale
            )
        } ?? "-"
        let lowestBalance = comparison.projected.minimumBalance?
            .currencyText(locale: locale) ?? "-"

        return [
            String(
                localized: "Projected balance: \(projectedBalance)",
                locale: locale
            ),
            String(
                localized: "Change: \(difference)",
                locale: locale
            ),
            String(
                localized: "Lowest balance: \(lowestBalance)",
                locale: locale
            ),
            String(
                localized: "Affected items: \(comparison.projected.changedItemCount)",
                locale: locale
            )
        ]
    }

    @ChartContentBuilder
    func zeroRuleMark() -> some ChartContent {
        RuleMark(y: .value("Zero", Double.zero))
            .foregroundStyle(.secondary.opacity(Metrics.zeroRuleOpacity))
            .lineStyle(
                .init(
                    lineWidth: Metrics.zeroRuleLineWidth,
                    dash: [Metrics.zeroRuleDashLength]
                )
            )
    }

    @ChartContentBuilder
    func currentBalanceMarks() -> some ChartContent {
        ForEach(comparison.monthlyBalances) { month in
            LineMark(
                x: .value("Month", month.monthDate),
                y: .value("Current", month.currentBalance)
            )
            .foregroundStyle(.secondary)
            .interpolationMethod(.linear)
            .lineStyle(.init(lineWidth: Metrics.currentLineWidth))

            PointMark(
                x: .value("Month", month.monthDate),
                y: .value("Current", month.currentBalance)
            )
            .foregroundStyle(.secondary)
        }
    }

    @ChartContentBuilder
    func projectedBalanceMarks() -> some ChartContent {
        ForEach(comparison.monthlyBalances) { month in
            LineMark(
                x: .value("Month", month.monthDate),
                y: .value("Projected", month.projectedBalance)
            )
            .foregroundStyle(.tint)
            .interpolationMethod(.linear)
            .lineStyle(.init(lineWidth: Metrics.projectedLineWidth))

            PointMark(
                x: .value("Month", month.monthDate),
                y: .value("Projected", month.projectedBalance)
            )
            .foregroundStyle(.tint)
        }
    }
}

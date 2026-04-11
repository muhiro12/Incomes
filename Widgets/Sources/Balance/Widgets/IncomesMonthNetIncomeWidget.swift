import MHDesign
import SwiftUI
import WidgetKit

struct IncomesMonthNetIncomeWidget {
    // swiftlint:disable:next type_contents_order
    private let kind: String = "com.muhiro12.Incomes.Widgets.MonthNetIncome"

    private struct ContentView: View {
        @Environment(\.mhDesignMetrics)
        private var designMetrics

        private let contentSpacing: CGFloat = 4
        let entry: NetIncomeEntry

        var body: some View {
            ViewThatFits(in: .horizontal) {
                mediumLayout
                compactLayout
            }
        }

        @ViewBuilder private var mediumLayout: some View {
            HStack(alignment: .center, spacing: designMetrics.spacing.control) {
                VStack(
                    alignment: .leading,
                    spacing: contentSpacing
                ) {
                    Text(IncomesMonthNetIncomeWidget.monthTitle(from: entry.date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .singleLine()
                    Text("Net Income")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .singleLine()
                }
                Spacer(minLength: 0)
                HStack(spacing: designMetrics.spacing.inline) {
                    amountIcon
                        .font(.body.weight(.semibold))
                    Text(entry.netIncomeText)
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                        .singleLine()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(designMetrics.spacing.control)
        }

        @ViewBuilder private var compactLayout: some View {
            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                Text(IncomesMonthNetIncomeWidget.monthTitle(from: entry.date))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .singleLine()
                Text("Net Income")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .singleLine()
                HStack(spacing: designMetrics.spacing.inline) {
                    amountIcon
                        .font(.footnote.weight(.semibold))
                    Text(entry.netIncomeText)
                        .font(.headline.weight(.semibold))
                        .monospacedDigit()
                        .singleLine()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(designMetrics.spacing.inline)
        }

        private var amountIcon: some View {
            Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                .foregroundStyle(entry.isPositive ? .green : .red)
                .accessibilityHidden(true)
        }
    }

    private static func monthTitle(from date: Date) -> String {
        Formatting.monthTitle(from: date)
    }
}

extension IncomesMonthNetIncomeWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: NetIncomeProvider()
        ) { entry in
            ContentView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(entry.deepLinkURL)
        }
        .configurationDisplayName("Incomes Net Income")
        .description("This month's net income")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview("Small", as: .systemSmall) {
    IncomesMonthNetIncomeWidget()
} timeline: {
    NetIncomeEntry(
        date: .now,
        configuration: .init(),
        netIncomeText: "$1,234",
        isPositive: true,
        deepLinkURL: nil
    )
}

#Preview("Medium", as: .systemMedium) {
    IncomesMonthNetIncomeWidget()
} timeline: {
    NetIncomeEntry(
        date: .now,
        configuration: .init(),
        netIncomeText: "$1,234",
        isPositive: true,
        deepLinkURL: nil
    )
}

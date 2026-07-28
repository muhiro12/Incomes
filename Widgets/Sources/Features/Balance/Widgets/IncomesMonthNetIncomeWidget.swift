import MHDesign
import SwiftUI
import WidgetKit

struct IncomesMonthNetIncomeWidget {
    private struct ContentView: View {
        @Environment(\.mhDesignMetrics)
        private var designMetrics

        let entry: NetIncomeEntry

        @ViewBuilder var body: some View {
            ViewThatFits(in: .horizontal) {
                mediumLayout
                compactLayout
            }
        }

        @ViewBuilder private var mediumLayout: some View {
            HStack(alignment: .center, spacing: designMetrics.spacing.control) {
                VStack(
                    alignment: .leading,
                    spacing: designMetrics.spacing.inline
                ) {
                    Text(IncomesMonthNetIncomeWidget.monthTitle(from: entry.targetDate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                    Text("Net Income")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                }
                Spacer(minLength: 0)
                HStack(spacing: designMetrics.spacing.inline) {
                    amountIcon
                        .font(.body.weight(.semibold))
                    Text(entry.netIncomeText)
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(designMetrics.spacing.control)
        }

        @ViewBuilder private var compactLayout: some View {
            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                Text(IncomesMonthNetIncomeWidget.monthTitle(from: entry.targetDate))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                Text("Net Income")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                HStack(spacing: designMetrics.spacing.inline) {
                    amountIcon
                        .font(.footnote.weight(.semibold))
                    Text(entry.netIncomeText)
                        .font(.headline.weight(.semibold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(designMetrics.spacing.inline)
        }

        private var amountIcon: some View {
            Image(systemName: amountSystemName)
                .foregroundStyle(amountColor)
                .accessibilityHidden(true)
        }

        private var amountColor: Color {
            switch entry.netIncomePresentation {
            case .positive:
                .green
            case .neutral:
                .secondary
            case .negative:
                .red
            }
        }

        private var amountSystemName: String {
            switch entry.netIncomePresentation {
            case .positive:
                "chevron.up"
            case .neutral:
                "minus"
            case .negative:
                "chevron.down"
            }
        }
    }

    private let kind = "com.muhiro12.Incomes.Widgets.MonthNetIncome"

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
        targetDate: .now,
        configuration: .init(),
        netIncomeText: "$1,234",
        netIncomePresentation: .positive,
        deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: .now)
    )
}

#Preview("Medium", as: .systemMedium) {
    IncomesMonthNetIncomeWidget()
} timeline: {
    NetIncomeEntry(
        date: .now,
        targetDate: .now,
        configuration: .init(),
        netIncomeText: "$1,234",
        netIncomePresentation: .positive,
        deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: .now)
    )
}

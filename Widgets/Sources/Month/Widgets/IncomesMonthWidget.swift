import MHDesign
import SwiftUI
import WidgetKit

struct IncomesMonthWidget {
    // swiftlint:disable:next type_contents_order
    private let kind: String = "com.muhiro12.Incomes.Widgets.Month"

    private struct ContentView: View {
        @Environment(\.mhDesignMetrics)
        private var designMetrics

        private let compactAmountIconWidth: CGFloat = 14
        private let compactMinScaleFactor = 0.7
        let entry: MonthSummaryEntry
        private let mediumMinScaleFactor = 0.8

        var body: some View {
            ViewThatFits(in: .horizontal) {
                mediumRoomyLayout
                mediumCompactLayout
                smallLayout
            }
        }

        private var mediumRoomyLayout: some View {
            HStack(alignment: .center, spacing: designMetrics.spacing.control) {
                monthInfo(font: .subheadline)
                Spacer(minLength: 0)
                amountGrid(
                    amountFont: .title2.weight(.semibold),
                    iconFont: .subheadline.weight(.semibold),
                    verticalSpacing: designMetrics.spacing.inline,
                    minimumScaleFactor: mediumMinScaleFactor
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(designMetrics.spacing.control)
        }

        private var mediumCompactLayout: some View {
            HStack(alignment: .center, spacing: designMetrics.spacing.inline) {
                monthInfo(font: .footnote)
                Spacer(minLength: 0)
                amountGrid(
                    amountFont: .title3.weight(.semibold),
                    iconFont: .caption.weight(.semibold),
                    verticalSpacing: designMetrics.spacing.inline,
                    minimumScaleFactor: compactMinScaleFactor
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(designMetrics.spacing.control)
        }

        private var smallLayout: some View {
            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                monthInfo(font: .footnote)
                smallAmountRow(
                    systemName: "chevron.up",
                    foregroundStyle: .green,
                    text: entry.totalIncomeText
                )
                smallAmountRow(
                    systemName: "chevron.down",
                    foregroundStyle: .red,
                    text: entry.totalOutgoText
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(designMetrics.spacing.inline)
        }

        @ViewBuilder
        private func monthInfo(font: Font) -> some View {
            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                Text(IncomesMonthWidget.monthTitle(from: entry.targetDate))
                    .font(font)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                Text("Income / Outgo")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
            }
        }

        private func amountGrid(
            amountFont: Font,
            iconFont: Font,
            verticalSpacing: CGFloat,
            minimumScaleFactor: CGFloat
        ) -> some View {
            Grid(
                alignment: .trailing,
                horizontalSpacing: designMetrics.spacing.inline,
                verticalSpacing: verticalSpacing
            ) {
                GridRow {
                    amountIcon(
                        systemName: "chevron.up",
                        foregroundStyle: .green,
                        font: iconFont
                    )
                    amountText(
                        entry.totalIncomeText,
                        font: amountFont,
                        minimumScaleFactor: minimumScaleFactor
                    )
                }
                GridRow {
                    amountIcon(
                        systemName: "chevron.down",
                        foregroundStyle: .red,
                        font: iconFont
                    )
                    amountText(
                        entry.totalOutgoText,
                        font: amountFont,
                        minimumScaleFactor: minimumScaleFactor
                    )
                }
            }
        }

        private func amountText(
            _ text: String,
            font: Font,
            minimumScaleFactor: CGFloat
        ) -> some View {
            Text(text)
                .font(font)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(minimumScaleFactor)
        }

        private func smallAmountRow(
            systemName: String,
            foregroundStyle: Color,
            text: String
        ) -> some View {
            HStack(spacing: designMetrics.spacing.inline) {
                amountIcon(
                    systemName: systemName,
                    foregroundStyle: foregroundStyle,
                    font: .caption.weight(.semibold)
                )
                .frame(
                    width: compactAmountIconWidth,
                    alignment: .leading
                )
                Text(text)
                    .font(.footnote.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
            }
        }

        private func amountIcon(
            systemName: String,
            foregroundStyle: Color,
            font: Font
        ) -> some View {
            Image(systemName: systemName)
                .font(font)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(foregroundStyle)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Helpers
    private static func monthTitle(from date: Date) -> String {
        Formatting.monthTitle(from: date)
    }
}

extension IncomesMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: MonthSummaryProvider()
        ) { entry in
            ContentView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(entry.deepLinkURL)
        }
        .configurationDisplayName("Incomes")
        .description("This month's items and balance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview("Small", as: .systemSmall) {
    IncomesMonthWidget()
} timeline: {
    MonthSummaryEntry(
        date: .now,
        targetDate: .now,
        configuration: .init(),
        totalIncomeText: "$1,200",
        totalOutgoText: "-$800",
        deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: .now)
    )
}

#Preview("Medium", as: .systemMedium) {
    IncomesMonthWidget()
} timeline: {
    MonthSummaryEntry(
        date: .now,
        targetDate: .now,
        configuration: .init(),
        totalIncomeText: "$1,200",
        totalOutgoText: "-$800",
        deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: .now)
    )
}

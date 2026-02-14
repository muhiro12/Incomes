import SwiftUI
import WidgetKit

struct IncomesMonthWidget {
    private let kind: String = "com.muhiro12.Incomes.Widgets.Month"

    // MARK: - Helpers
    private static func monthTitle(from date: Date) -> String {
        Formatting.monthTitle(from: date)
    }
}

extension IncomesMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: MonthSummaryProvider()) { entry in
            ViewThatFits(in: .horizontal) {
                // Medium (roomy) layout: horizontal split
                HStack(alignment: .center, spacing: .space(.m)) {
                    VStack(alignment: .leading, spacing: .space(.xs)) {
                        Text(Self.monthTitle(from: entry.date))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .singleLine()
                        Text("Income / Outgo")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .singleLine()
                    }
                    Spacer(minLength: 0)
                    Grid(alignment: .trailing, horizontalSpacing: .space(.s), verticalSpacing: .space(.s)) {
                        GridRow {
                            Image(systemName: "chevron.up")
                                .font(.subheadline.weight(.semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.green)
                            Text(entry.totalIncomeText)
                                .font(.title2.weight(.semibold))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        GridRow {
                            Image(systemName: "chevron.down")
                                .font(.subheadline.weight(.semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.red)
                            Text(entry.totalOutgoText)
                                .font(.title2.weight(.semibold))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.space(.m))

                // Medium (compact) layout: horizontal split
                HStack(alignment: .center, spacing: .space(.s)) {
                    VStack(alignment: .leading, spacing: .space(.xs)) {
                        Text(Self.monthTitle(from: entry.date))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .singleLine()
                        Text("Income / Outgo")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .singleLine()
                    }
                    Spacer(minLength: 0)
                    Grid(alignment: .trailing, horizontalSpacing: .space(.s), verticalSpacing: .space(.xs)) {
                        GridRow {
                            Image(systemName: "chevron.up")
                                .font(.caption.weight(.semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.green)
                            Text(entry.totalIncomeText)
                                .font(.title3.weight(.semibold))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        GridRow {
                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.red)
                            Text(entry.totalOutgoText)
                                .font(.title3.weight(.semibold))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.space(.m))

                // Small (compact) layout: vertical stack
                VStack(alignment: .leading, spacing: .space(.s)) {
                    Text(Self.monthTitle(from: entry.date))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .singleLine()
                    Text("Income / Outgo")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .singleLine()
                    HStack(spacing: .space(.s)) {
                        Image(systemName: "chevron.up")
                            .font(.caption.weight(.semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.green)
                            .frame(width: 14, alignment: .leading)
                        Text(entry.totalIncomeText)
                            .font(.footnote.weight(.semibold))
                            .monospacedDigit()
                            .singleLine()
                    }
                    HStack(spacing: .space(.s)) {
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.red)
                            .frame(width: 14, alignment: .leading)
                        Text(entry.totalOutgoText)
                            .font(.footnote.weight(.semibold))
                            .monospacedDigit()
                            .singleLine()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.space(.s))
            }
            .containerBackground(.fill.tertiary, for: .widget)
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
        configuration: .init(),
        totalIncomeText: "$1,200",
        totalOutgoText: "-$800"
    )
}

#Preview("Medium", as: .systemMedium) {
    IncomesMonthWidget()
} timeline: {
    MonthSummaryEntry(
        date: .now,
        configuration: .init(),
        totalIncomeText: "$1,200",
        totalOutgoText: "-$800"
    )
}

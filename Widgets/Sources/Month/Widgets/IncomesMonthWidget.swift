import SwiftUI
import WidgetKit

struct IncomesMonthWidget {
    let kind: String = "IncomesMonthWidget"

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
                            .lineLimit(1)
                            .minimumScaleFactor(.minimumScaleFactor)
                        Text("Income / Outgo")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing, spacing: .space(.s)) {
                        HStack(spacing: .space(.s)) {
                            Image(systemName: "chevron.up")
                                .foregroundStyle(.accent)
                            Text(entry.totalIncomeText)
                                .font(.title3)
                                .lineLimit(1)
                                .minimumScaleFactor(.minimumScaleFactor)
                        }
                        HStack(spacing: .space(.s)) {
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.red)
                            Text(entry.totalOutgoText)
                                .font(.title3)
                                .lineLimit(1)
                                .minimumScaleFactor(.minimumScaleFactor)
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
                        .lineLimit(1)
                        .minimumScaleFactor(.minimumScaleFactor)
                    Text("Income / Outgo")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    HStack(spacing: .space(.s)) {
                        Image(systemName: "chevron.up")
                            .foregroundStyle(.accent)
                        Text(entry.totalIncomeText)
                            .lineLimit(1)
                            .minimumScaleFactor(.minimumScaleFactor)
                    }
                    .font(.footnote)
                    HStack(spacing: .space(.s)) {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.red)
                        Text(entry.totalOutgoText)
                            .lineLimit(1)
                            .minimumScaleFactor(.minimumScaleFactor)
                    }
                    .font(.footnote)
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

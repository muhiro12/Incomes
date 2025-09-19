import SwiftUI
import WidgetKit

struct IncomesMonthBalanceWidget {
    let kind: String = "IncomesMonthBalanceWidget"

    // MARK: - Helpers
    private static func monthTitle(from date: Date) -> String {
        let formatter: DateFormatter = .init()
        formatter.locale = .current
        formatter.dateFormat = "yyyy MMM"
        return formatter.string(from: date)
    }
}

extension IncomesMonthBalanceWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: BalanceProvider()) { entry in
            ViewThatFits(in: .horizontal) {
                // Medium (roomy) layout: horizontal split
                HStack(alignment: .center, spacing: .space(.m)) {
                    VStack(alignment: .leading, spacing: .space(.xs)) {
                        Text(Self.monthTitle(from: entry.date))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(.minimumScaleFactor)
                        Text("Balance")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    HStack(spacing: .space(.s)) {
                        Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                            .foregroundStyle(entry.isPositive ? .accent : .red)
                        Text(entry.balanceText)
                            .font(.title3)
                            .lineLimit(1)
                            .minimumScaleFactor(.minimumScaleFactor)
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
                    Text("Balance")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    HStack(spacing: .space(.s)) {
                        Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                            .foregroundStyle(entry.isPositive ? .accent : .red)
                        Text(entry.balanceText)
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(.minimumScaleFactor)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.space(.s))
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Incomes Balance")
        .description("This month's net balance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview("Small", as: .systemSmall) {
    IncomesMonthBalanceWidget()
} timeline: {
    BalanceEntry(
        date: .now,
        configuration: .init(),
        balanceText: "$1,234",
        isPositive: true
    )
}

#Preview("Medium", as: .systemMedium) {
    IncomesMonthBalanceWidget()
} timeline: {
    BalanceEntry(
        date: .now,
        configuration: .init(),
        balanceText: "$1,234",
        isPositive: true
    )
}

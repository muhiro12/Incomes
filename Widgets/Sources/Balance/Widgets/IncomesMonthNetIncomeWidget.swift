import SwiftUI
import WidgetKit

struct IncomesMonthNetIncomeWidget {
    private let kind: String = "com.muhiro12.Incomes.Widgets.MonthNetIncome"

    private static func monthTitle(from date: Date) -> String {
        let formatter: DateFormatter = .init()
        formatter.locale = .current
        formatter.dateFormat = "yyyy MMM"
        return formatter.string(from: date)
    }
}

extension IncomesMonthNetIncomeWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: NetIncomeProvider()) { entry in
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: .space(.m)) {
                    VStack(alignment: .leading, spacing: .space(.xs)) {
                        Text(Self.monthTitle(from: entry.date))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .singleLine()
                        Text("Net Income")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .singleLine()
                    }
                    Spacer(minLength: 0)
                    HStack(spacing: .space(.s)) {
                        Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                            .foregroundStyle(entry.isPositive ? .accent : .red)
                        Text(entry.netIncomeText)
                            .font(.title3)
                            .singleLine()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.space(.m))

                VStack(alignment: .leading, spacing: .space(.s)) {
                    Text(Self.monthTitle(from: entry.date))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .singleLine()
                    Text("Net Income")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .singleLine()
                    HStack(spacing: .space(.s)) {
                        Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                            .foregroundStyle(entry.isPositive ? .accent : .red)
                        Text(entry.netIncomeText)
                            .font(.headline)
                            .singleLine()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.space(.s))
            }
            .containerBackground(.fill.tertiary, for: .widget)
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
        isPositive: true
    )
}

#Preview("Medium", as: .systemMedium) {
    IncomesMonthNetIncomeWidget()
} timeline: {
    NetIncomeEntry(
        date: .now,
        configuration: .init(),
        netIncomeText: "$1,234",
        isPositive: true
    )
}

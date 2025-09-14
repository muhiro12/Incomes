import SwiftUI
import WidgetKit

struct IncomesMonthWidget: Widget {
    let kind: String = "IncomesMonthWidget"

    // MARK: - Helpers
    private static func monthTitle(from date: Date) -> String {
        let formatter: DateFormatter = .init()
        formatter.locale = .current
        formatter.dateFormat = "yyyy MMM"
        return formatter.string(from: date)
    }

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: MonthSummaryProvider()) { entry in
            VStack(alignment: .leading, spacing: 8) {
                Text(Self.monthTitle(from: entry.date))
                    .font(.headline)

                HStack(spacing: 8) {
                    Text("Total Income")
                    Spacer(minLength: 0)
                    Text(entry.totalIncomeText)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up")
                        .foregroundStyle(Color.accentColor)
                }
                .font(.footnote)
                .padding(.leading, 12)

                HStack(spacing: 8) {
                    Text("Total Outgo")
                    Spacer(minLength: 0)
                    Text(entry.totalOutgoText)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.red)
                }
                .font(.footnote)
                .padding(.leading, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(12)
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

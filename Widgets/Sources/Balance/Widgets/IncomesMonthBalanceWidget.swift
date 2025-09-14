import SwiftUI
import WidgetKit

struct IncomesMonthBalanceWidget: Widget {
    let kind: String = "IncomesMonthBalanceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: BalanceProvider()) { entry in
            BalanceEntryView(entry: entry)
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

// MARK: - Inline View for Preview and Composition

struct BalanceEntryView: View {
    var entry: BalanceEntry

    private var monthTitle: String {
        let formatter: DateFormatter = .init()
        formatter.locale = .current
        formatter.dateFormat = "yyyy MMM"
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthTitle)
                .font(.headline)

            HStack(spacing: 8) {
                Text("Balance")
                Spacer(minLength: 0)
                Text(entry.balanceText)
                    .foregroundStyle(.secondary)
                Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                    .foregroundStyle(entry.isPositive ? Color.accentColor : Color.red)
            }
            .font(.footnote)
            .padding(.leading, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
    }
}

#Preview("Positive (View)") {
    BalanceEntryView(
        entry: .init(
            date: .now,
            configuration: .init(),
            balanceText: "$1,234",
            isPositive: true
        )
    )
}

#Preview("Negative (View)") {
    BalanceEntryView(
        entry: .init(
            date: .now,
            configuration: .init(),
            balanceText: "-$567",
            isPositive: false
        )
    )
}

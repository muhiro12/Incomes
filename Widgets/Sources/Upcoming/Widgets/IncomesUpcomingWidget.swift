import SwiftUI
import WidgetKit

struct IncomesUpcomingWidget: Widget {
    let kind: String = "IncomesUpcomingWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: UpcomingConfigurationAppIntent.self, provider: UpcomingProvider()) { entry in
            UpcomingEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Upcoming Item")
        .description("Shows the next or previous item")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview("Small", as: .systemSmall) {
    IncomesUpcomingWidget()
} timeline: {
    UpcomingEntry(
        date: .now,
        titleText: "Sep 14 (Sat)",
        detailText: "Utility bill",
        amountText: "-$80",
        isPositive: false
    )
}

#Preview("Medium", as: .systemMedium) {
    IncomesUpcomingWidget()
} timeline: {
    UpcomingEntry(
        date: .now,
        titleText: "Sep 14 (Sat)",
        detailText: "Grocery",
        amountText: "-$45",
        isPositive: false
    )
}

// MARK: - Inline View for Preview and Composition

struct UpcomingEntryView: View {
    var entry: UpcomingEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.titleText)
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(entry.detailText)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(entry.amountText)
                        .foregroundStyle(.secondary)
                    Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                        .foregroundStyle(entry.isPositive ? Color.accentColor : Color.red)
                }
                .font(.footnote)
                .padding(.leading, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
    }
}

#Preview("Income (View)") {
    UpcomingEntryView(
        entry: .init(
            date: .now,
            titleText: "Sep 14 (Sat)",
            detailText: "Salary",
            amountText: "$3,000",
            isPositive: true
        )
    )
}

#Preview("Outgo (View)") {
    UpcomingEntryView(
        entry: .init(
            date: .now,
            titleText: "Sep 16 (Mon)",
            detailText: "Rent",
            amountText: "-$1,200",
            isPositive: false
        )
    )
}

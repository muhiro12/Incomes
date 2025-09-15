import SwiftUI
import WidgetKit

struct IncomesUpcomingWidget: Widget {
    let kind: String = "IncomesUpcomingWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: UpcomingConfigurationAppIntent.self, provider: UpcomingProvider()) { entry in
            ViewThatFits(in: .horizontal) {
                // Medium (roomy) layout: horizontal split
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.titleText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        HStack(spacing: 6) {
                            Text(entry.subtitleText)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Text("•")
                                .foregroundStyle(.tertiary)
                            Text(entry.detailText)
                                .font(.footnote)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                    Spacer(minLength: 0)
                    HStack(spacing: 6) {
                        Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                            .foregroundStyle(entry.isPositive ? .accent : .red)
                        Text(entry.amountText)
                            .font(.title3)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(12)

                // Small (compact) layout: vertical stack
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.titleText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    HStack(spacing: 6) {
                        Text(entry.subtitleText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(entry.detailText)
                            .font(.footnote)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                            .foregroundStyle(entry.isPositive ? .accent : .red)
                        Text(entry.amountText)
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(8)
            }
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
        subtitleText: "Next",
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
        subtitleText: "Next",
        titleText: "Sep 14 (Sat)",
        detailText: "Grocery",
        amountText: "-$45",
        isPositive: false
    )
}

import SwiftUI
import WidgetKit

struct IncomesUpcomingWidget {
    private let kind: String = "com.muhiro12.Incomes.Widgets.Upcoming"
}

extension IncomesUpcomingWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: UpcomingConfigurationAppIntent.self, provider: UpcomingProvider()) { entry in
            ViewThatFits(in: .horizontal) {
                // Medium (roomy) layout: horizontal split
                HStack(alignment: .center, spacing: .space(.m)) {
                    VStack(alignment: .leading, spacing: .space(.xs)) {
                        Text(entry.titleText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .singleLine()
                        HStack(spacing: .space(.s)) {
                            Text(entry.subtitleText)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .singleLine()
                            Text("•")
                                .foregroundStyle(.tertiary)
                            Text(entry.detailText)
                                .font(.footnote)
                                .singleLine()
                        }
                    }
                    Spacer(minLength: 0)
                    HStack(spacing: .space(.s)) {
                        Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                            .font(.subheadline.weight(.semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(entry.isPositive ? .green : .red)
                        Text(entry.amountText)
                            .font(.title2.weight(.semibold))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.space(.m))

                // Small (compact) layout: vertical stack
                VStack(alignment: .leading, spacing: .space(.s)) {
                    Text(entry.titleText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .singleLine()
                    HStack(spacing: .space(.s)) {
                        Text(entry.subtitleText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .singleLine()
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(entry.detailText)
                            .font(.footnote)
                            .singleLine()
                    }
                    HStack(spacing: .space(.s)) {
                        Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(entry.isPositive ? .green : .red)
                        Text(entry.amountText)
                            .font(.headline.weight(.semibold))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.space(.s))
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

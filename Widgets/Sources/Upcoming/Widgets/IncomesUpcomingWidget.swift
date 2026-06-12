import MHDesign
import SwiftUI
import WidgetKit

struct IncomesUpcomingWidget {
    // swiftlint:disable:next type_contents_order
    private let kind: String = "com.muhiro12.Incomes.Widgets.Upcoming"

    private struct ContentView: View {
        @Environment(\.mhDesignMetrics)
        private var designMetrics

        private let compactMinScaleFactor = 0.85
        let entry: UpcomingEntry
        private let mediumMinScaleFactor = 0.8

        var body: some View {
            ViewThatFits(in: .horizontal) {
                mediumLayout
                compactLayout
            }
        }

        @ViewBuilder private var mediumLayout: some View {
            HStack(alignment: .center, spacing: designMetrics.spacing.control) {
                VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                    entry.titleText
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                    HStack(spacing: designMetrics.spacing.inline) {
                        entry.subtitleText
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                        Text("•")
                            .foregroundStyle(.tertiary)
                        entry.detailText
                            .font(.footnote)
                            .lineLimit(1)
                            .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                    }
                }
                Spacer(minLength: 0)
                HStack(spacing: designMetrics.spacing.inline) {
                    amountIcon
                        .font(.subheadline.weight(.semibold))
                    Text(verbatim: entry.amountText)
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(mediumMinScaleFactor)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(designMetrics.spacing.control)
        }

        @ViewBuilder private var compactLayout: some View {
            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                entry.titleText
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                HStack(spacing: designMetrics.spacing.inline) {
                    entry.subtitleText
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                    Text("•")
                        .foregroundStyle(.tertiary)
                    entry.detailText
                        .font(.footnote)
                        .lineLimit(1)
                        .minimumScaleFactor(WidgetTextScaling.minimumScaleFactor)
                }
                HStack(spacing: designMetrics.spacing.inline) {
                    amountIcon
                        .font(.caption.weight(.semibold))
                    Text(verbatim: entry.amountText)
                        .font(.headline.weight(.semibold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(compactMinScaleFactor)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(designMetrics.spacing.inline)
        }

        private var amountIcon: some View {
            Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(entry.isPositive ? .green : .red)
                .accessibilityHidden(true)
        }
    }
}

extension IncomesUpcomingWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: UpcomingConfigurationAppIntent.self,
            provider: UpcomingProvider()
        ) { entry in
            ContentView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(entry.deepLinkURL)
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
        subtitleText: Text("Next"),
        titleText: Text(verbatim: "Sep 14 (Sat)"),
        detailText: Text(verbatim: "Utility bill"),
        amountText: "-$80",
        isPositive: false,
        deepLinkURL: WidgetDeepLinkBuilder.homeURL()
    )
}

#Preview("Medium", as: .systemMedium) {
    IncomesUpcomingWidget()
} timeline: {
    UpcomingEntry(
        date: .now,
        subtitleText: Text("Next"),
        titleText: Text(verbatim: "Sep 14 (Sat)"),
        detailText: Text(verbatim: "Grocery"),
        amountText: "-$45",
        isPositive: false,
        deepLinkURL: WidgetDeepLinkBuilder.homeURL()
    )
}

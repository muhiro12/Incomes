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

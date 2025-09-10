import SwiftUI
import WidgetKit

struct IncomesMonthWidget: Widget {
    let kind: String = "IncomesMonthWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: MonthSummaryProvider()) { entry in
            MonthSummaryEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Incomes")
        .description("This month's items and balance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

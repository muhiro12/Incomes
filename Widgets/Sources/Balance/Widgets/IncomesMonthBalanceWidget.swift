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

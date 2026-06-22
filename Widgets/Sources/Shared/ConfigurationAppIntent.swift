import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Incomes widgets configuration" }

    @Parameter(title: "Target Month", default: .currentMonth)
    var targetMonth: MonthSelection
}

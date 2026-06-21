import AppIntents
import WidgetKit

struct UpcomingConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Upcoming Configuration" }
    static var description: IntentDescription { "Configure upcoming widget direction" }

    @Parameter(title: "Direction", default: .next)
    var direction: UpcomingDirection
}

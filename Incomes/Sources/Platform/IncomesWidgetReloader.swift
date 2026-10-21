import WidgetKit

enum IncomesWidgetReloader {
    static func reloadAllWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: IncomesWidgetIdentifiers.month)
        WidgetCenter.shared.reloadTimelines(ofKind: IncomesWidgetIdentifiers.monthNetIncome)
        WidgetCenter.shared.reloadTimelines(ofKind: IncomesWidgetIdentifiers.upcoming)
    }
}

import WidgetKit

enum IncomesWidgetReloader {
    private enum WidgetKind {
        static let month = "com.muhiro12.Incomes.Widgets.Month"
        static let monthNetIncome = "com.muhiro12.Incomes.Widgets.MonthNetIncome"
        static let upcoming = "com.muhiro12.Incomes.Widgets.Upcoming"
    }

    static func reloadAllWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.month)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.monthNetIncome)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.upcoming)
    }
}

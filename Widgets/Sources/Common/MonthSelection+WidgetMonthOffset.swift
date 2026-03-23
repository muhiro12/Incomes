import IncomesLibrary

extension MonthSelection {
    var widgetMonthOffset: WidgetMonthOffset {
        switch self {
        case .previousMonth:
            .previous
        case .currentMonth:
            .current
        case .nextMonth:
            .next
        }
    }
}

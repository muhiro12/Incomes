/// Selects which month a widget should target relative to the current date.
public enum WidgetMonthOffset: Int, Sendable {
    case previous = -1
    case current = 0
    case next = 1
}

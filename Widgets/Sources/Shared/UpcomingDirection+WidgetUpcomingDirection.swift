import IncomesLibrary

extension UpcomingDirection {
    var widgetUpcomingDirection: WidgetUpcomingDirection {
        switch self {
        case .next:
            .next
        case .previous:
            .previous
        }
    }
}

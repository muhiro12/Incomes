import AppIntents

enum MonthSelection: String, AppEnum {
    case previousMonth
    case currentMonth
    case nextMonth

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Target Month")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .previousMonth: .init(title: "Previous Month"),
            .currentMonth: .init(title: "Current Month"),
            .nextMonth: .init(title: "Next Month")
        ]
    }
}

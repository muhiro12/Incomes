import AppIntents

enum UpcomingDirection: String, AppEnum {
    case next
    case previous

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Direction")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .next: .init(title: "Next"),
            .previous: .init(title: "Previous")
        ]
    }
}

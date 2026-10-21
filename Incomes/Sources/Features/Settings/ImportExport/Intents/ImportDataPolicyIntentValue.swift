import AppIntents

enum ImportDataPolicyIntentValue: String, AppEnum {
    case merge
    case replace

    static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "Import Policy")
    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .merge: .init(title: "Merge"),
        .replace: .init(title: "Replace")
    ]

    var policy: ItemImportPolicy {
        switch self {
        case .merge:
            .merge(.init())
        case .replace:
            .replace
        }
    }
}

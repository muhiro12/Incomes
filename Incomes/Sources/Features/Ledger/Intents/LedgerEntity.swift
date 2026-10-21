import AppIntents

/// Uses the same store-local identity and default role as the ledger UI.
struct LedgerEntity: AppEntity {
    static let defaultQuery = LedgerEntityQuery()
    static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(
        name: .init("Ledger", table: "AppIntents")
    )

    let id: String
    @Property(title: "Ledger Name")
    var name: String
    private let displayTitle: String

    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(displayTitle)", image: .init(systemName: "books.vertical"))
    }

    var identifier: LedgerIdentifier {
        .init(rawValue: id)
    }

    init(_ ledger: LedgerRecord, names: [LedgerIdentifier: String] = [:]) {
        id = ledger.id.rawValue
        displayTitle = LedgerSelectionTitle.title(identifier: ledger.id, name: ledger.name, names: names)
        name = ledger.name
    }
}

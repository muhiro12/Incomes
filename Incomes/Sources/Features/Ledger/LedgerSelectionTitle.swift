/// Disambiguates repeated names without treating the displayed name as identity.
enum LedgerSelectionTitle {
    private static let initialSuffixLength = 6

    static func title(identifier: LedgerIdentifier, name: String, names: [LedgerIdentifier: String]) -> String {
        let peers = names.filter { $0.value == name }
        guard peers.count > 1 else {
            return name
        }
        var length = initialSuffixLength
        while Set(peers.keys.map { $0.rawValue.suffix(length) }).count != peers.count {
            length += 1
        }
        return "\(name) (\(identifier.rawValue.suffix(length)))"
    }
}

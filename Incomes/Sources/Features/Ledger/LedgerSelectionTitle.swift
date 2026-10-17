/// Disambiguates repeated names without treating the displayed name as identity.
enum LedgerSelectionTitle {
    static func title(identifier: LedgerIdentifier, name: String, names: [LedgerIdentifier: String]) -> String {
        let peers = names.filter { $0.value == name }.map(\.key).sorted { $0.rawValue < $1.rawValue }
        guard peers.count > 1, let index = peers.firstIndex(of: identifier) else {
            return name
        }
        return "\(name) (\(index + 1))"
    }
}

/// Canonical in-app destinations that can be represented by external URLs.
public enum IncomesRoute: Equatable, Sendable {
    case home
    case settings
    case year(Int)
    case month(year: Int, month: Int)
    case search(query: String?)
}

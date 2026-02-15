/// Canonical in-app destinations that can be represented by external URLs.
public enum IncomesRoute: Equatable, Sendable {
    case home
    case settings
    case settingsSubscription
    case settingsLicense
    case settingsDebug
    case yearSummary(Int)
    case yearlyDuplication
    case introduction
    case duplicateTags
    case year(Int)
    case month(year: Int, month: Int)
    case search(query: String?)
}

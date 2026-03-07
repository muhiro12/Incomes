import Foundation

/// Shared defaults used by route URL parsing and building.
public enum IncomesRouteURLDefaults {
    /// Custom URL scheme used by the app.
    public static let customScheme = "incomes"
    /// Host name used for universal links.
    public static let universalLinkHost = "muhiro12.github.io"
    /// Associated Domains prefix used for the universal-link entitlement.
    public static let universalLinkAssociatedDomainPrefix = "applinks"
    /// App path prefix appended to universal-link routes.
    public static let universalLinkPathPrefix = "Incomes"

    /// Associated Domains entry combining the prefix and host.
    public static var universalLinkAssociatedDomain: String {
        "\(universalLinkAssociatedDomainPrefix):\(universalLinkHost)"
    }
}

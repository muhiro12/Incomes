import Foundation

/// Shared defaults used by route URL parsing and building.
public enum IncomesRouteURLDefaults {
    public static let customScheme = "incomes"
    public static let routeVersionPathSegment = "v1"
    public static let universalLinkHost = "muhiro12.github.io"
    public static let universalLinkAssociatedDomainPrefix = "applinks"
    public static let universalLinkPathPrefix = "Incomes"

    public static var universalLinkAssociatedDomain: String {
        "\(universalLinkAssociatedDomainPrefix):\(universalLinkHost)"
    }
}

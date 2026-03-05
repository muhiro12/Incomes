import Foundation

/// Shared defaults used by route URL parsing and building.
public enum IncomesRouteURLDefaults {
    /// Documented for SwiftLint compliance.
    public static let customScheme = "incomes"
    /// Documented for SwiftLint compliance.
    public static let universalLinkHost = "muhiro12.github.io"
    /// Documented for SwiftLint compliance.
    public static let universalLinkAssociatedDomainPrefix = "applinks"
    /// Documented for SwiftLint compliance.
    public static let universalLinkPathPrefix = "Incomes"

    /// Documented for SwiftLint compliance.
    public static var universalLinkAssociatedDomain: String {
        "\(universalLinkAssociatedDomainPrefix):\(universalLinkHost)"
    }
}

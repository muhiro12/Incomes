import Foundation

/// Parses incoming URLs and maps them to app navigation routes.
public enum IncomesRouteParser {
    /// Documented for SwiftLint compliance.
    public static let customScheme = IncomesRouteURLDefaults.customScheme
    /// Documented for SwiftLint compliance.
    public static let universalLinkHosts: Set<String> = [
        IncomesRouteURLDefaults.universalLinkHost
    ]

    /// Documented for SwiftLint compliance.
    public static func parse(
        url: URL,
        allowedUniversalLinkHosts: Set<String> = universalLinkHosts
    ) -> IncomesRoute? {
        let codec = IncomesDeepLinkCodec.make(
            allowedUniversalLinkHosts: allowedUniversalLinkHosts
        )
        return codec.parse(url)
    }
}

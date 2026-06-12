import Foundation

/// Parses incoming URLs and maps them to app navigation routes.
public enum IncomesRouteParser {
    /// Default custom URL scheme accepted by the parser.
    public static let customScheme = IncomesRouteURLDefaults.customScheme
    /// Default universal-link hosts accepted by the parser.
    public static let universalLinkHosts: Set<String> = [
        IncomesRouteURLDefaults.universalLinkHost
    ]

    /// Parses `url` into an `IncomesRoute` when it matches a supported transport.
    public static func parse(
        url: URL,
        allowedUniversalLinkHosts: Set<String> = universalLinkHosts,
        universalLinkPathPrefix: String = IncomesRouteURLDefaults.universalLinkPathPrefix
    ) -> IncomesRoute? {
        let codec = IncomesDeepLinkCodec.make(
            allowedUniversalLinkHosts: allowedUniversalLinkHosts,
            appPathPrefix: universalLinkPathPrefix
        )
        return codec.parse(url)
    }
}

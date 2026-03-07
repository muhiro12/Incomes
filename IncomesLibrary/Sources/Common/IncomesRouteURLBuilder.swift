import Foundation

/// Builds shareable URLs from app routes.
public enum IncomesRouteURLBuilder {
    /// Default custom scheme used when building custom-scheme URLs.
    public static let customScheme = IncomesRouteURLDefaults.customScheme
    /// Default host used when building universal links.
    public static let defaultUniversalLinkHost = IncomesRouteURLDefaults.universalLinkHost
    /// Default app path prefix used when building universal links.
    public static let defaultUniversalLinkPathPrefix = IncomesRouteURLDefaults.universalLinkPathPrefix

    /// Builds a custom-scheme URL for `route`.
    public static func customSchemeURL(
        for route: IncomesRoute
    ) -> URL? {
        IncomesDeepLinkCodec.shared.url(
            for: route,
            transport: .customScheme
        )
    }

    /// Builds a universal-link URL for `route` using the supplied host settings.
    public static func universalLinkURL(
        for route: IncomesRoute,
        host: String = defaultUniversalLinkHost,
        appPathPrefix: String = defaultUniversalLinkPathPrefix
    ) -> URL? {
        let codec = IncomesDeepLinkCodec.make(
            host: host,
            appPathPrefix: appPathPrefix
        )
        return codec.url(
            for: route,
            transport: .universalLink
        )
    }
}

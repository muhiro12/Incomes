import Foundation

/// Builds shareable URLs from app routes.
public enum IncomesRouteURLBuilder {
    /// Documented for SwiftLint compliance.
    public static let customScheme = IncomesRouteURLDefaults.customScheme
    /// Documented for SwiftLint compliance.
    public static let defaultUniversalLinkHost = IncomesRouteURLDefaults.universalLinkHost
    /// Documented for SwiftLint compliance.
    public static let defaultUniversalLinkPathPrefix = IncomesRouteURLDefaults.universalLinkPathPrefix

    /// Documented for SwiftLint compliance.
    public static func customSchemeURL(
        for route: IncomesRoute
    ) -> URL? {
        IncomesDeepLinkCodec.shared.url(
            for: route,
            transport: .customScheme
        )
    }

    /// Documented for SwiftLint compliance.
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

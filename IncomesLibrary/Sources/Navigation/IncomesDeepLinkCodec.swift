import MHPlatformCore

/// Builds the shared deep-link codec used by Incomes routes.
public enum IncomesDeepLinkCodec {
    /// Shared codec instance for decoding incoming Incomes deep links.
    public static let shared = make()

    /// Creates a codec configured for Incomes deep-link transports.
    public static func make(
        host: String = IncomesRouteURLDefaults.universalLinkHost,
        appPathPrefix: String = IncomesRouteURLDefaults.universalLinkPathPrefix,
        preferredTransport: MHDeepLinkTransport = .universalLink
    ) -> MHDeepLinkCodec<IncomesRoute> {
        make(
            host: host,
            allowedUniversalLinkHosts: [host],
            appPathPrefix: appPathPrefix,
            preferredTransport: preferredTransport
        )
    }

    /// Creates a codec configured for specific accepted universal-link hosts.
    public static func make(
        host: String,
        allowedUniversalLinkHosts: Set<String>,
        appPathPrefix: String = IncomesRouteURLDefaults.universalLinkPathPrefix,
        preferredTransport: MHDeepLinkTransport = .universalLink
    ) -> MHDeepLinkCodec<IncomesRoute> {
        .init(
            configuration: .init(
                customScheme: IncomesRouteURLDefaults.customScheme,
                preferredUniversalLinkHost: host,
                allowedUniversalLinkHosts: allowedUniversalLinkHosts,
                universalLinkPathPrefix: appPathPrefix,
                preferredTransport: preferredTransport
            )
        )
    }

    /// Creates a codec using the default preferred host with specific accepted hosts.
    public static func make(
        allowedUniversalLinkHosts: Set<String>,
        appPathPrefix: String = IncomesRouteURLDefaults.universalLinkPathPrefix,
        preferredTransport: MHDeepLinkTransport = .universalLink
    ) -> MHDeepLinkCodec<IncomesRoute> {
        make(
            host: IncomesRouteURLDefaults.universalLinkHost,
            allowedUniversalLinkHosts: allowedUniversalLinkHosts,
            appPathPrefix: appPathPrefix,
            preferredTransport: preferredTransport
        )
    }
}

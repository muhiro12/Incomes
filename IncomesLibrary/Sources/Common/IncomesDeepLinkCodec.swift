import MHPlatform

/// Builds the shared deep-link codec used by Incomes routes.
public enum IncomesDeepLinkCodec {
    /// Shared codec instance for decoding incoming Incomes deep links.
    public static let shared = make()

    /// Creates a codec configured for Incomes deep-link transports.
    public static func make(
        host: String = IncomesRouteURLDefaults.universalLinkHost,
        allowedUniversalLinkHosts: Set<String> = [
            IncomesRouteURLDefaults.universalLinkHost
        ],
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
}

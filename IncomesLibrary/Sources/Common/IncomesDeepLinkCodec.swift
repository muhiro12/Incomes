import MHDeepLinking

enum IncomesDeepLinkCodec {
    static let shared = make()

    static func make(
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

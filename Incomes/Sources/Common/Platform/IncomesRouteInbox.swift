import Observation

@MainActor
@Observable
final class IncomesRouteInbox {
    private(set) var pendingRoute: IncomesRoute?

    func ingest(_ route: IncomesRoute) {
        pendingRoute = route
    }

    func consumeLatest() -> IncomesRoute? {
        let route = pendingRoute
        pendingRoute = nil
        return route
    }
}

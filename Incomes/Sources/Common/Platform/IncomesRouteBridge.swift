import Foundation
import Observation

@MainActor
@Observable
final class IncomesRouteBridge {
    typealias Handler = @MainActor @Sendable (IncomesRoute) async throws -> Void
    typealias Resynchronization = @MainActor @Sendable () async -> Void

    struct HandlerUnavailableError: LocalizedError, Sendable {
        var errorDescription: String? {
            "Route handler is unavailable."
        }
    }

    @ObservationIgnored private var handler: Handler?

    @ObservationIgnored private var resynchronization: Resynchronization?

    private var pendingRoute: IncomesRoute?

    func registerHandler(
        _ handler: @escaping Handler
    ) {
        self.handler = handler
    }

    func unregisterHandler() {
        handler = nil
    }

    func apply(
        _ route: IncomesRoute
    ) async throws {
        guard let handler else {
            pendingRoute = route
            throw HandlerUnavailableError()
        }

        do {
            try await handler(route)
            if pendingRoute == route {
                pendingRoute = nil
            }
        } catch {
            pendingRoute = route
            throw error
        }
    }

    func configureResynchronization(
        _ resynchronization: @escaping Resynchronization
    ) {
        self.resynchronization = resynchronization
    }

    func resynchronizePendingRoutesIfPossible() async {
        if let pendingRoute {
            do {
                try await apply(pendingRoute)
            } catch {
                // Keep the latest route buffered and continue with upstream sources.
            }
        }

        await resynchronization?()
    }
}

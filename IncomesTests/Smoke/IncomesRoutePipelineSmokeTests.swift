import Foundation
@testable import Incomes
import IncomesLibrary
import MHAppRuntime
import MHDeepLinking
import MHRouteExecution
import Testing

@MainActor
struct IncomesRoutePipelineSmokeTests {
    @Test
    func preview_environment_delivers_pending_route_from_runtime_bootstrap() async throws {
        let environment = try makePreviewEnvironment()
        let bootstrapRouteInbox = try #require(
            environment.runtimeBootstrap.routeInbox
        )
        let routeURL = try #require(
            IncomesRouteURLBuilder.customSchemeURL(for: .settings)
        )

        await bootstrapRouteInbox.ingest(routeURL)
        _ = await environment.routePipeline.synchronizePendingRoutesIfPossible()

        #expect(environment.routeInbox.pendingRoute == .settings)
        #expect(environment.routePipeline.lastParseFailureURL == nil)
    }

    @Test
    func preview_environment_retains_parse_failure_for_invalid_route() async throws {
        let environment = try makePreviewEnvironment()
        let bootstrapRouteInbox = try #require(
            environment.runtimeBootstrap.routeInbox
        )
        let invalidURL = try #require(
            URL(string: "https://muhiro12.github.io/Incomes/unknown")
        )

        await bootstrapRouteInbox.ingest(invalidURL)
        _ = await environment.routePipeline.synchronizePendingRoutesIfPossible()

        #expect(environment.routeInbox.pendingRoute == nil)
        #expect(environment.routePipeline.lastParseFailureURL == invalidURL)

        environment.routePipeline.clearLastParseFailure()

        #expect(environment.routePipeline.lastParseFailureURL == nil)
    }
}

@MainActor
private func makePreviewEnvironment() throws -> IncomesPlatformEnvironment {
    let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()

    return IncomesPlatformEnvironmentFactory.make(
        modelContainer: modelContainer,
        platformMode: .preview
    )
}

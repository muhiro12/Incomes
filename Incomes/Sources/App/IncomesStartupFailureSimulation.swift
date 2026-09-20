import Foundation

/// Debug-only hook that reproduces a startup failure without touching a store.
enum IncomesStartupFailureSimulation {
    #if DEBUG
    private struct SimulatedFailure: Error {}

    static let argumentPrefix = "--incomes-ui-smoke-fail-startup="

    /// Throws when the launch arguments request a failure for `phase`.
    static func failIfRequested(
        phase: IncomesStartupFailurePhase,
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) throws {
        let requestedPhases = arguments.compactMap { argument in
            argument.hasPrefix(argumentPrefix)
                ? String(argument.dropFirst(argumentPrefix.count))
                : nil
        }
        guard requestedPhases.contains(phase.rawValue) else {
            return
        }
        throw SimulatedFailure()
    }
    #else
    static func failIfRequested(phase _: IncomesStartupFailurePhase) {
        // Release builds never simulate a startup failure.
    }
    #endif
}

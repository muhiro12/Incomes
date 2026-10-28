import Foundation

/// Debug-only launch options used to verify startup paths without touching a store.
enum IncomesStartupDebugOptions {
    #if DEBUG
    private struct SimulatedFailure: Error {}

    static let failureArgumentPrefix = "--incomes-ui-smoke-fail-startup="
    /// Set to false and rebuild to create an empty development database.
    /// Existing data is preserved regardless of this setting.
    static let automaticallySeedsSampleData = true
    #endif

    /// Throws when the launch arguments request a failure for `phase`.
    static func failIfRequested(
        phase: IncomesStartupFailurePhase,
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) throws {
        #if DEBUG
        let requestedPhases = arguments.compactMap { argument in
            argument.hasPrefix(failureArgumentPrefix)
                ? String(argument.dropFirst(failureArgumentPrefix.count))
                : nil
        }
        guard requestedPhases.contains(phase.rawValue) else {
            return
        }
        throw SimulatedFailure()
        #else
        _ = (phase, arguments)
        #endif
    }
}

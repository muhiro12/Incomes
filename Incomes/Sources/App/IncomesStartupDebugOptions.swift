import Foundation

/// Debug-only launch options used to verify startup paths without touching a store.
enum IncomesStartupDebugOptions {
    #if DEBUG
    private struct SimulatedFailure: Error {}

    static let failureArgumentPrefix = "--incomes-ui-smoke-fail-startup="
    static let forcedICloudArgument = "--incomes-ui-smoke-icloud-on"
    #endif

    /// True when the launch arguments ask for a CloudKit-backed container.
    static var isICloudForced: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains(forcedICloudArgument)
        #else
        return false
        #endif
    }

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

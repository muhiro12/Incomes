import Foundation
import MHPlatformCore
import Observation

/// Shares scheduled update evidence between presentation and data-mutation adapters.
@preconcurrency
@MainActor
@Observable
public final class RemoteUpdateOperations {
    /// Whether the app has chosen scheduled update enforcement.
    public let isEnabled: Bool
    /// The latest diagnostic snapshot, shared by presentation and mutation adapters.
    public private(set) var evaluation: MHRemoteUpdateEvaluation?

    /// The decision from the same observed instant; unavailable is never permission to write.
    public var decision: MHRemoteUpdateDecision {
        evaluation?.decision ?? .unavailable
    }

    private let controller: MHRemoteUpdateController?
    private let configurationError: (any Error)?

    /// Disables networking and update enforcement for previews and isolated environments.
    public init() {
        isEnabled = false
        controller = nil
        configurationError = nil
    }

    /// Enables enforcement using one package-owned controller for this environment.
    public init(controller: MHRemoteUpdateController) {
        isEnabled = true
        self.controller = controller
        configurationError = nil
    }

    /// Keeps a failed configuration blocking instead of implicitly allowing mutations.
    public init(configurationError: any Error) {
        isEnabled = true
        controller = nil
        self.configurationError = configurationError
    }

    /// Restores and refreshes evidence using the package's standard recovery sequence.
    @discardableResult
    public func prepare() async throws -> MHRemoteUpdateController.Preparation? {
        try Task.checkCancellation()
        if let configurationError {
            throw configurationError
        }
        guard let controller else {
            return nil
        }
        let preparation = try await controller.prepare()
        evaluation = preparation.evaluation
        return preparation
    }

    /// Confirms permission immediately before a user-requested data write and its success effects.
    public func checkMutationAllowed() async throws {
        try Task.checkCancellation()
        guard isEnabled else {
            return
        }
        guard let controller else {
            throw RemoteUpdateError.policyUnavailable
        }
        do {
            try await controller.checkOperationAllowed()
            evaluation = await controller.evaluation()
            try Task.checkCancellation()
            try decision.checkOperationAllowed(whenUnavailable: .block)
        } catch {
            evaluation = await controller.evaluation()
            if error is CancellationError || Task.isCancelled {
                throw CancellationError()
            }
            if (error as? MHRemoteUpdateOperationError) == .updateRequired {
                throw RemoteUpdateError.updateRequired
            }
            throw RemoteUpdateError.policyUnavailable
        }
    }

    /// Runs a synchronous mutation and its success effects without another suspension after confirmation.
    public func performMutation<Value>(
        _ operation: () throws -> Value
    ) async throws -> Value {
        try await checkMutationAllowed()
        try Task.checkCancellation()
        return try operation()
    }
}

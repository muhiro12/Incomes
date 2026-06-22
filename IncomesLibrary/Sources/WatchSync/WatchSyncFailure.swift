import Foundation

public struct WatchSyncFailure: Codable, Sendable, Error, Equatable {
    public let phase: WatchSyncFailurePhase
    public let message: String

    public init(
        phase: WatchSyncFailurePhase,
        message: String
    ) {
        self.phase = phase
        self.message = message
    }
}

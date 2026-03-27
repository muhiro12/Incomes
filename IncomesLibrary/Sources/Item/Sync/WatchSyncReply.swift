import Foundation

public struct WatchSyncReply: Codable, Sendable {
    public enum Status: String, Codable, Sendable, Equatable {
        case success
        case failure
    }

    public let status: Status
    public let items: [ItemWire]
    public let failure: WatchSyncFailure?

    public var isSuccess: Bool {
        status == .success
    }

    public var shouldApplySnapshot: Bool {
        isSuccess
    }

    public static func success(items: [ItemWire]) -> Self {
        .init(
            status: .success,
            items: items,
            failure: nil
        )
    }

    public static func failed(_ failure: WatchSyncFailure) -> Self {
        .init(
            status: .failure,
            items: [],
            failure: failure
        )
    }

    public static func failed(
        phase: WatchSyncFailurePhase,
        message: String
    ) -> Self {
        .failed(
            .init(
                phase: phase,
                message: message
            )
        )
    }

    public static func failed(
        phase: WatchSyncFailurePhase,
        error: any Error
    ) -> Self {
        .failed(
            phase: phase,
            message: error.localizedDescription
        )
    }

    public static func decodeResponse(_ data: Data) -> Self {
        do {
            return try JSONDecoder().decode(
                Self.self,
                from: data
            )
        } catch {
            return .failed(
                phase: .responseDecode,
                error: error
            )
        }
    }
}

import Foundation

/// Identifies a request for the Watch app to refresh its existing pull-based snapshot.
public struct WatchSyncRefreshSignal: Equatable, Sendable {
    private static let applicationContextKey = "watchSyncRefreshSignalID"

    /// Stable identifier used to deduplicate repeated application-context delivery.
    public let id: UUID

    /// Property-list-compatible context sent through WatchConnectivity.
    public var applicationContext: [String: Any] {
        [Self.applicationContextKey: id.uuidString]
    }

    /// Creates a refresh signal.
    public init(id: UUID = .init()) {
        self.id = id
    }

    /// Creates a refresh signal from a WatchConnectivity application context.
    public init?(applicationContext: [String: Any]) {
        guard let idString = applicationContext[Self.applicationContextKey] as? String,
              let id = UUID(uuidString: idString) else {
            return nil
        }

        self.id = id
    }
}

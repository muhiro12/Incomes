/// Tracks the newest successfully applied Watch synchronization payload.
public struct WatchSyncWatermark: Sendable {
    /// Phone generation epoch of the newest successful synchronization.
    ///
    /// A legacy live reply without a phone epoch falls back to its request epoch.
    public private(set) var latestEpoch: Double?

    public init() {
        // Start without an accepted synchronization payload.
    }

    /// Returns whether an application context is newer than all applied data.
    public func shouldApplyApplicationContext(
        generatedEpoch: Double
    ) -> Bool {
        guard let latestEpoch else {
            return true
        }

        return generatedEpoch > latestEpoch
    }

    /// Advances the watermark after a live pull and local snapshot apply succeed.
    public mutating func recordPullResult(
        _ result: WatchSyncReply,
        request: ItemsRequest
    ) {
        guard result.isSuccess else {
            return
        }

        advance(
            to: result.phoneGeneratedEpoch ?? request.baseEpoch
        )
    }

    /// Advances the watermark after an application context is applied locally.
    public mutating func recordApplicationContextResult(
        _ result: WatchSyncReply,
        generatedEpoch: Double
    ) {
        guard result.isSuccess else {
            return
        }

        advance(
            to: result.phoneGeneratedEpoch ?? generatedEpoch
        )
    }
}

private extension WatchSyncWatermark {
    mutating func advance(
        to epoch: Double
    ) {
        latestEpoch = max(latestEpoch ?? epoch, epoch)
    }
}

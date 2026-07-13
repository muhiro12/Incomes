import Foundation

/// Encodes the latest watch snapshot as a replaceable WatchConnectivity context.
public enum WatchSyncApplicationContext {
    /// An application context prepared within the configured byte limit.
    public struct PreparedContext {
        /// Property-list-compatible dictionary ready for `WCSession`.
        public let applicationContext: [String: Any]
        /// Number of reply items retained in the bounded payload.
        public let includedItemCount: Int
        /// Encoded JSON payload size in bytes.
        public let payloadByteCount: Int
    }

    /// A decoded snapshot together with the request window that produced it.
    public struct Snapshot: Sendable {
        /// Identifier used to avoid applying the same context more than once.
        public let id: UUID
        /// Time at which the phone generated this replaceable snapshot.
        public let generatedEpoch: Double
        /// Request window used to build `reply`.
        public let request: ItemsRequest
        /// Phone-produced snapshot reply.
        public let reply: WatchSyncReply
    }

    /// Failures that occur before the encoded context payload can be decoded.
    public enum ContextError: Error, Equatable, Sendable {
        case missingPayload
        case payloadExceedsLimit(
                minimumByteCount: Int,
                maximumByteCount: Int
             )
        case unsupportedSchemaVersion(Int)
    }

    /// Conservative maximum for the JSON data stored in an application context.
    ///
    /// The remaining space below the transport limit is reserved for the
    /// property-list dictionary and its key.
    public static let maximumPayloadByteCount =
        payloadBudgetKibibytes * bytesPerKibibyte

    /// Creates a property-list-compatible context for `WCSession`.
    public static func make(
        request: ItemsRequest,
        reply: WatchSyncReply
    ) throws -> [String: Any] {
        try prepare(
            request: request,
            reply: reply
        ).applicationContext
    }

    /// Creates a context whose encoded payload stays below the transport budget.
    ///
    /// When necessary, the reply is reduced to its longest fitting item prefix,
    /// preserving the deterministic order supplied by the snapshot query.
    public static func prepare(
        request: ItemsRequest,
        reply: WatchSyncReply
    ) throws -> PreparedContext {
        let phoneGeneratedEpoch = reply.phoneGeneratedEpoch
            ?? Date.now.timeIntervalSince1970
        return try prepare(
            request: request,
            reply: reply,
            maximumPayloadByteCount: maximumPayloadByteCount,
            phoneGeneratedEpoch: phoneGeneratedEpoch
        )
    }

    /// Decodes the latest context and validates its schema version.
    public static func snapshot(
        from applicationContext: [String: Any]
    ) throws -> Snapshot {
        guard let data = applicationContext[payloadKey] as? Data else {
            throw ContextError.missingPayload
        }

        let payload = try JSONDecoder().decode(
            Payload.self,
            from: data
        )
        guard payload.schemaVersion == currentSchemaVersion else {
            throw ContextError.unsupportedSchemaVersion(
                payload.schemaVersion
            )
        }

        return .init(
            id: payload.id,
            generatedEpoch: payload.reply.phoneGeneratedEpoch
                ?? payload.generatedEpoch,
            request: payload.request,
            reply: payload.reply
        )
    }

    static func prepare(
        request: ItemsRequest,
        reply: WatchSyncReply,
        maximumPayloadByteCount: Int,
        phoneGeneratedEpoch: Double
    ) throws -> PreparedContext {
        let payloadID = UUID()
        let boundedPayload = try boundedPayload(
            request: request,
            reply: reply,
            payloadID: payloadID,
            phoneGeneratedEpoch: phoneGeneratedEpoch,
            maximumPayloadByteCount: maximumPayloadByteCount
        )

        return .init(
            applicationContext: [
                payloadKey: boundedPayload.data
            ],
            includedItemCount: boundedPayload.payload.reply.items.count,
            payloadByteCount: boundedPayload.data.count
        )
    }
}

private extension WatchSyncApplicationContext {
    struct Payload: Codable, Sendable {
        let schemaVersion: Int
        let id: UUID
        let generatedEpoch: Double
        let request: ItemsRequest
        let reply: WatchSyncReply
    }

    struct EncodedPayload {
        let payload: Payload
        let data: Data
    }

    static let currentSchemaVersion = 1
    static let payloadKey = "com.muhiro12.Incomes.watchSyncSnapshot"
    static let payloadBudgetKibibytes = 60
    static let bytesPerKibibyte = 1_024
    static let binarySearchDivisor = 2

    static func boundedPayload(
        request: ItemsRequest,
        reply: WatchSyncReply,
        payloadID: UUID,
        phoneGeneratedEpoch: Double,
        maximumPayloadByteCount: Int
    ) throws -> EncodedPayload {
        var lowerItemCount = 0
        var upperItemCount = reply.items.count
        var bestPayload: EncodedPayload?

        while lowerItemCount <= upperItemCount {
            let itemCount = lowerItemCount
                + (upperItemCount - lowerItemCount) / binarySearchDivisor
            let payload = payload(
                request: request,
                reply: reply,
                itemCount: itemCount,
                payloadID: payloadID,
                phoneGeneratedEpoch: phoneGeneratedEpoch
            )
            let data = try JSONEncoder().encode(payload)

            if data.count <= maximumPayloadByteCount {
                bestPayload = .init(
                    payload: payload,
                    data: data
                )
                lowerItemCount = itemCount + 1
            } else {
                upperItemCount = itemCount - 1
            }
        }

        guard let bestPayload else {
            let minimumPayload = payload(
                request: request,
                reply: reply,
                itemCount: 0,
                payloadID: payloadID,
                phoneGeneratedEpoch: phoneGeneratedEpoch
            )
            let minimumByteCount = try JSONEncoder()
                .encode(minimumPayload)
                .count
            throw ContextError.payloadExceedsLimit(
                minimumByteCount: minimumByteCount,
                maximumByteCount: maximumPayloadByteCount
            )
        }

        return bestPayload
    }

    static func payload(
        request: ItemsRequest,
        reply: WatchSyncReply,
        itemCount: Int,
        payloadID: UUID,
        phoneGeneratedEpoch: Double
    ) -> Payload {
        .init(
            schemaVersion: currentSchemaVersion,
            id: payloadID,
            generatedEpoch: phoneGeneratedEpoch,
            request: request,
            reply: .init(
                status: reply.status,
                items: Array(reply.items.prefix(itemCount)),
                currencyCode: reply.currencyCode,
                phoneGeneratedEpoch: phoneGeneratedEpoch,
                failure: reply.failure
            )
        )
    }
}

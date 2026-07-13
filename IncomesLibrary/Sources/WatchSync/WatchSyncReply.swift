import Foundation

private let kResponseEncodeFallbackData = Data(
    """
    {
      "status":"failure",
      "items":[],
      "failure":{
        "phase":"responseEncode",
        "message":"Failed to encode watch sync reply"
      }
    }
    """.utf8
)

public struct WatchSyncReply: Codable, Sendable {
    public enum Status: String, Codable, Sendable, Equatable {
        case success
        case failure
    }

    public let status: Status
    public let items: [ItemWire]
    /// Currency code selected by the paired iPhone, when supplied by the sender.
    public let currencyCode: String?
    /// Time at which the paired iPhone generated this snapshot.
    public let phoneGeneratedEpoch: Double?
    public let failure: WatchSyncFailure?

    public var isSuccess: Bool {
        status == .success
    }

    public var shouldApplySnapshot: Bool {
        isSuccess
    }

    /// True when the reply succeeded without returning any item payloads.
    public var isEmptySuccess: Bool {
        isSuccess && items.isEmpty
    }

    public static func success(
        items: [ItemWire],
        currencyCode: String? = nil,
        phoneGeneratedEpoch: Double? = nil
    ) -> Self {
        .init(
            status: .success,
            items: items,
            currencyCode: currencyCode,
            phoneGeneratedEpoch: phoneGeneratedEpoch,
            failure: nil
        )
    }

    public static func failed(_ failure: WatchSyncFailure) -> Self {
        .init(
            status: .failure,
            items: [],
            currencyCode: nil,
            phoneGeneratedEpoch: nil,
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

    public static func responseData(
        for reply: Self
    ) throws -> Data {
        try JSONEncoder().encode(reply)
    }

    /// Encodes a reply, falling back to a response-encode failure payload.
    public static func encodedResponseData(
        for reply: Self,
        onEncodingFailure: (any Error) -> Void
    ) -> Data {
        do {
            return try responseData(for: reply)
        } catch {
            onEncodingFailure(error)
            return responseEncodingFailureData(error: error)
        }
    }

    public static func responseEncodingFailureData(
        error: any Error
    ) -> Data {
        let fallbackReply = Self.failed(
            phase: .responseEncode,
            error: error
        )
        return (try? responseData(for: fallbackReply))
            ?? kResponseEncodeFallbackData
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

import Foundation

public enum WatchSyncFailurePhase: Codable, Sendable, Equatable {
    case requestDecode
    case missingContext
    case itemFetch
    case responseEncode
    case sessionUnreachable
    case requestEncode
    case transport
    case responseDecode
    case snapshotApply

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let wireValue = try container.decode(String.self)
        guard let phase = Self(wireValue: wireValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown watch sync failure phase: \(wireValue)"
            )
        }

        self = phase
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wireValue)
    }
}

public extension WatchSyncFailurePhase {
    /// True when the failure indicates the paired iPhone could not be reached.
    var isConnectivityFailure: Bool {
        switch self {
        case .sessionUnreachable,
             .transport:
            true
        case .requestDecode,
             .missingContext,
             .itemFetch,
             .responseEncode,
             .requestEncode,
             .responseDecode,
             .snapshotApply:
            false
        }
    }
}

private extension WatchSyncFailurePhase {
    var wireValue: String {
        switch self {
        case .requestDecode:
            "requestDecode"
        case .missingContext:
            "missingContext"
        case .itemFetch:
            "itemFetch"
        case .responseEncode:
            "responseEncode"
        case .sessionUnreachable:
            "sessionUnreachable"
        case .requestEncode:
            "requestEncode"
        case .transport:
            "transport"
        case .responseDecode:
            "responseDecode"
        case .snapshotApply:
            "snapshotApply"
        }
    }

    init?(wireValue: String) {
        switch wireValue {
        case "requestDecode":
            self = .requestDecode
        case "missingContext":
            self = .missingContext
        case "itemFetch":
            self = .itemFetch
        case "responseEncode":
            self = .responseEncode
        case "sessionUnreachable":
            self = .sessionUnreachable
        case "requestEncode":
            self = .requestEncode
        case "transport":
            self = .transport
        case "responseDecode":
            self = .responseDecode
        case "snapshotApply":
            self = .snapshotApply
        default:
            return nil
        }
    }
}

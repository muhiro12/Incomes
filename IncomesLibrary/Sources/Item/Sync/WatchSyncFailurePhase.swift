import Foundation

// swiftlint:disable redundant_string_enum_value
public enum WatchSyncFailurePhase: String, Codable, Sendable, Equatable {
    case requestDecode = "requestDecode"
    case missingContext = "missingContext"
    case itemFetch = "itemFetch"
    case responseEncode = "responseEncode"
    case sessionUnreachable = "sessionUnreachable"
    case requestEncode = "requestEncode"
    case transport = "transport"
    case responseDecode = "responseDecode"
    case snapshotApply = "snapshotApply"
}
// swiftlint:enable redundant_string_enum_value

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

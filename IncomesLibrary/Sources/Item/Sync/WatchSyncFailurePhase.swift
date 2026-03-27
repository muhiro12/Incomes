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

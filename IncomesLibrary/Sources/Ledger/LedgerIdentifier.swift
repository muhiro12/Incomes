import Foundation

/// Portable identity for one person's independent financial book, not a login account.
public struct LedgerIdentifier: RawRepresentable, Codable, Hashable, Sendable, Identifiable {
    /// The original book, represented by the absence of a dedicated ownership Tag.
    public static let `default`: Self = .init(rawValue: "default")
    static let conflicting: Self = .init(rawValue: "conflicting")

    /// Stable storage and wire value, independent of the displayed name.
    public let rawValue: String

    /// Identity used by value-based selection controls.
    public var id: String {
        rawValue
    }

    /// Creates an identity without changing an unknown explicit identifier.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a new identity without a device-local incremental counter.
    public init() {
        rawValue = UUID().uuidString
    }

    public init(from decoder: any Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

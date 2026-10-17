import Foundation

/// A ledger reference within a store or an import file; imports resolve their own references.
public struct LedgerIdentifier: RawRepresentable, Codable, Hashable, Sendable, Identifiable {
    /// The original book, represented by the absence of a dedicated ownership Tag.
    public static let `default`: Self = .init(rawValue: "default")
    static let conflicting: Self = .init(rawValue: "conflicting")

    /// Encoded Tag identity, or a file-scoped reference awaiting import resolution.
    public let rawValue: String

    /// Identity used by value-based selection controls.
    public var id: String {
        rawValue
    }

    /// Creates an identity without changing an unknown explicit identifier.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a file-scoped reference without claiming a destination store identity.
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

import Foundation

public struct ItemWire: Codable, Sendable {
    /// Current JSON schema emitted by `ItemWire`.
    public static let currentSchemaVersion = 2

    public let dateEpoch: Double
    public let content: String
    public let income: Decimal
    public let outgo: Decimal
    public let category: String

    public init(
        dateEpoch: Double,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) {
        self.dateEpoch = dateEpoch
        self.content = content
        self.income = income
        self.outgo = outgo
        self.category = category
    }

    /// Creates a wire value from legacy floating-point amount inputs.
    @_disfavoredOverload
    public init(
        dateEpoch: Double,
        content: String,
        income: Double,
        outgo: Double,
        category: String
    ) {
        self.init(
            dateEpoch: dateEpoch,
            content: content,
            income: Decimal(income),
            outgo: Decimal(outgo),
            category: category
        )
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try container.decodeIfPresent(
            Int.self,
            forKey: .schemaVersion
        ) ?? 1

        guard (1...Self.currentSchemaVersion).contains(schemaVersion) else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported item wire schema version: \(schemaVersion)"
            )
        }

        dateEpoch = try container.decode(Double.self, forKey: .dateEpoch)
        content = try container.decode(String.self, forKey: .content)
        income = try Self.decodeAmount(
            schemaVersion: schemaVersion,
            exactKey: .incomeDecimal,
            legacyKey: .income,
            container: container
        )
        outgo = try Self.decodeAmount(
            schemaVersion: schemaVersion,
            exactKey: .outgoDecimal,
            legacyKey: .outgo,
            container: container
        )
        category = try container.decode(String.self, forKey: .category)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(
            Self.currentSchemaVersion,
            forKey: .schemaVersion
        )
        try container.encode(dateEpoch, forKey: .dateEpoch)
        try container.encode(content, forKey: .content)
        try container.encode(
            Self.legacyDouble(from: income),
            forKey: .income
        )
        try container.encode(
            Self.legacyDouble(from: outgo),
            forKey: .outgo
        )
        try container.encode(
            income.description,
            forKey: .incomeDecimal
        )
        try container.encode(
            outgo.description,
            forKey: .outgoDecimal
        )
        try container.encode(category, forKey: .category)
    }
}

private extension ItemWire {
    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case dateEpoch
        case content
        case income
        case outgo
        case incomeDecimal
        case outgoDecimal
        case category
    }

    static let decimalLocale = Locale(identifier: "en_US_POSIX")

    static func legacyDouble(from amount: Decimal) throws -> Double {
        guard let value = Double(amount.description),
              value.isFinite else {
            throw EncodingError.invalidValue(
                amount,
                .init(
                    codingPath: [],
                    debugDescription: "Decimal cannot be represented as a legacy Double"
                )
            )
        }

        return value
    }

    static func decodeAmount(
        schemaVersion: Int,
        exactKey: CodingKeys,
        legacyKey: CodingKeys,
        container: KeyedDecodingContainer<CodingKeys>
    ) throws -> Decimal {
        guard schemaVersion >= currentSchemaVersion else {
            return .init(
                try container.decode(Double.self, forKey: legacyKey)
            )
        }

        let exactValue = try container.decode(String.self, forKey: exactKey)
        guard let amount = Decimal(
            string: exactValue,
            locale: decimalLocale
        ) else {
            throw DecodingError.dataCorruptedError(
                forKey: exactKey,
                in: container,
                debugDescription: "Invalid decimal amount: \(exactValue)"
            )
        }

        return amount
    }
}

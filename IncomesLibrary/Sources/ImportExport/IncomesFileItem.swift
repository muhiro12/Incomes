import Foundation

/// One item as an Incomes file records it, independent of the persistent model.
public struct IncomesFileItem: Equatable, Sendable {
    /// Fields a file item is decoded from, used to locate invalid input.
    public enum Field: String, Sendable {
        case date
        case content
        case income
        case outgo
        case category
        case priority
        case repeatID
        case balance
    }

    /// Stable owner; old files resolve only to the original default ledger.
    public let ledgerIdentifier: LedgerIdentifier

    /// Stored calendar day at UTC midnight, matching `Item.utcDate`.
    public let date: Date
    /// Item description.
    public let content: String
    /// Exact income amount.
    public let income: Decimal
    /// Exact outgo amount.
    public let outgo: Decimal
    /// Stored category name, or empty when the item has no category.
    public let category: String
    /// Display priority among items on the same day.
    public let priority: Int
    /// Repeat-series identifier, preserved on import.
    public let repeatID: UUID
    /// Running balance written for readers; import always recalculates it.
    public let balance: Decimal?

    public init(
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int,
        repeatID: UUID,
        balance: Decimal?,
        ledgerIdentifier: LedgerIdentifier = .default
    ) {
        self.date = date
        self.content = content
        self.income = income
        self.outgo = outgo
        self.category = category
        self.priority = priority
        self.repeatID = repeatID
        self.balance = balance
        self.ledgerIdentifier = ledgerIdentifier
    }
}

public extension IncomesFileItem {
    /// Local calendar date for the stored day, derived like `Item.localDate`.
    var localDate: Date {
        Calendar.current.shiftedDate(componentsFrom: date, in: .utc)
    }
}

extension IncomesFileItem {
    /// Stored values that recreate this item through `Item.create`.
    var storedValues: ItemStoredValues {
        .init(
            date: localDate,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority,
            ledgerIdentifier: ledgerIdentifier
        )
    }

    init(item: Item, derivedBalance: Decimal? = nil) {
        self.init(
            date: item.utcDate,
            content: item.content,
            income: item.income,
            outgo: item.outgo,
            category: item.category?.name ?? "",
            priority: item.priority,
            repeatID: item.repeatID,
            balance: derivedBalance,
            ledgerIdentifier: item.ledgerIdentifier
        )
    }

    /// Orders items by their values alone, so the order never depends on store identity.
    static func sortedByValue(_ items: [Self]) -> [Self] {
        items.sorted { left, right in
            left.isOrderedByValue(before: right)
        }
    }

    func isOrderedByValue(before other: Self) -> Bool {
        if ledgerIdentifier != other.ledgerIdentifier {
            return ledgerIdentifier.rawValue < other.ledgerIdentifier.rawValue
        }
        if date != other.date {
            return date < other.date
        }
        if priority != other.priority {
            return priority > other.priority
        }
        if content != other.content {
            return content < other.content
        }
        if income != other.income {
            return income < other.income
        }
        if outgo != other.outgo {
            return outgo < other.outgo
        }
        if category != other.category {
            return category < other.category
        }
        if repeatID != other.repeatID {
            return repeatID.uuidString < other.repeatID.uuidString
        }
        return (balance ?? .zero) < (other.balance ?? .zero)
    }

    func assigning(to identifier: LedgerIdentifier) -> Self {
        .init(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority,
            repeatID: repeatID,
            balance: balance,
            ledgerIdentifier: identifier
        )
    }
}

import Foundation
import SwiftData

/// A read-only view of saved running balances scoped to one book.
public struct LedgerBalanceSnapshot: Sendable {
    public let ledgerIdentifier: LedgerIdentifier
    public let balances: [PersistentIdentifier: Decimal]
    public let latestBalance: Decimal
    public let minimumBalance: Decimal?
}

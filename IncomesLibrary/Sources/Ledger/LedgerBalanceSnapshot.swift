import Foundation
import SwiftData

/// Derived balances that never use the legacy global Item.balance as financial truth.
public struct LedgerBalanceSnapshot: Sendable {
    public let ledgerIdentifier: LedgerIdentifier
    public let balances: [PersistentIdentifier: Decimal]
    public let latestBalance: Decimal
    public let minimumBalance: Decimal?
}

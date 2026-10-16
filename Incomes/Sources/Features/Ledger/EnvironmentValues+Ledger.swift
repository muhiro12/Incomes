import SwiftData
import SwiftUI

extension EnvironmentValues {
    @Entry var ledgerIsAvailable = true
    @Entry var ledgerIdentifier = LedgerIdentifier.default
    @Entry var ledgerBalances: [PersistentIdentifier: Decimal] = [:]
}

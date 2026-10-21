/// Whether an import retains exported balance baselines or explicitly rebuilds them.
public enum ItemImportBalancePolicy: Equatable, Sendable {
    /// Keep balances supplied by the file; calculate missing balances from the preceding saved value.
    case preserveSavedBalances
    /// Recalculate only the affected suffix of each ledger from its preceding saved balance.
    case recalculate
}

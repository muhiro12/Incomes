import SwiftUI

/// A detected difference is a choice, not proof that a saved balance is wrong.
struct DataImportBalanceSection: View {
    let hasDifferences: Bool
    let hasAmbiguousOrder: Bool
    let canRecalculate: Bool
    @Binding var recalculatesBalances: Bool

    var body: some View {
        Section {
            if hasDifferences {
                Text("Saved balances differ from recalculation using the recorded income and expenses.")
            }
            if hasAmbiguousOrder {
                Text("Some tied items may change order and displayed balances when restored.")
            }
            Toggle("Recalculate imported balances", isOn: $recalculatesBalances)
                .disabled(!canRecalculate && !recalculatesBalances)
            if !canRecalculate {
                Text("Recalculation exceeds the supported amount range. Saved balances can still be restored.")
            }
        } header: {
            Text("Balances")
        } footer: {
            VStack(alignment: .leading) {
                Text("Saved balances are kept unless you choose recalculation.")
                Text("Recalculation starts at the earliest imported change in each ledger.")
                Text("Earlier history and the preceding saved balance are kept.")
            }
        }
    }
}

#Preview {
    Form {
        DataImportBalanceSection(
            hasDifferences: true,
            hasAmbiguousOrder: true,
            canRecalculate: true,
            recalculatesBalances: .constant(false)
        )
    }
}

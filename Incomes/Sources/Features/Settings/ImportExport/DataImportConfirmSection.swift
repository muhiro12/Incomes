import SwiftUI

struct DataImportConfirmSection: View {
    let plannedResult: ItemImportResult
    /// Store items a merge keeps because the file does not contain them.
    let keptCount: Int?
    let isReplacing: Bool
    let isApplying: Bool
    var canApply = true
    let confirm: () -> Void

    var body: some View {
        Section {
            if plannedResult.changedLedgerCount > .zero {
                LabeledContent("Ledgers to update") { Text(plannedResult.changedLedgerCount, format: .number) }
            }
            LabeledContent("Items to add") {
                Text(plannedResult.addedCount, format: .number)
            }
            LabeledContent("Items to remove") {
                Text(plannedResult.removedCount, format: .number)
            }
            LabeledContent("Unchanged items") {
                Text(plannedResult.unchangedCount, format: .number)
            }
            if let keptCount, keptCount > .zero {
                LabeledContent("Kept items not in the file") {
                    Text(keptCount, format: .number)
                }
            }
            Button(role: isReplacing ? .destructive : nil, action: confirm) {
                HStack {
                    Text(isReplacing ? "Replace data" : "Import")
                    if isApplying {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(isApplying || isEmpty || !canApply)
        } header: {
            Text("Summary")
        } footer: {
            if !canApply { Text(LedgerError.premiumRequired.localizedDescription) }
        }
    }
}

private extension DataImportConfirmSection {
    var isEmpty: Bool {
        plannedResult.addedCount == .zero && plannedResult.removedCount == .zero
            && plannedResult.changedLedgerCount == .zero
    }
}

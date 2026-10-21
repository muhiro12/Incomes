import MHPlatform
import SwiftData
import SwiftUI

struct LedgerSettingsView: View {
    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn

    @Environment(\.modelContext)
    private var context
    let identifier: LedgerIdentifier
    @State private var name = ""
    @State private var errorMessage: String?
    @State private var isMutating = false

    var body: some View {
        Form {
            Section {
                TextField("Ledger Name", text: $name)
                    .ledgerWriteAccess(owner: identifier)
                Button("Rename") {
                    let newName = name
                    IncomesMutationWorkflow.performDataMutation(
                        errorMessage: $errorMessage,
                        isProcessing: $isMutating
                    ) {
                        try LedgerMutationAccess.requireEditing([identifier])
                        try LedgerOperations.rename(identifier, to: newName, context: context)
                    }
                }
                .disabled(
                    !LedgerAccessOperations.canEdit(identifier, isPremium: isSubscribeOn)
                )
            } header: {
                Text("Ledger Name")
            } footer: {
                if !LedgerAccessOperations.canEdit(identifier, isPremium: isSubscribeOn) {
                    VStack(alignment: .leading) {
                        Text("Read Only: The Monthly Plan is required to edit this ledger.")
                        Text(
                            """
                            After your subscription ends, existing ledgers remain available to view, switch, and export.
                            """
                        )
                    }
                }
            }
        }
        .navigationTitle("Ledger Settings")
        .task {
            name = (try? LedgerOperations.ledger(identifier, context: context).name) ?? ""
        }
        .alert(
            "Ledger Unavailable",
            isPresented: .init(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
        ) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

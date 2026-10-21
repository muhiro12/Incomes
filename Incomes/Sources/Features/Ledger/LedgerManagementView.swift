import MHDesign
import MHPlatform
import SwiftData
import SwiftUI

struct LedgerManagementView: View {
    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn

    @Environment(\.modelContext)
    private var context
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.mhDesignMetrics)
    private var designMetrics
    @Query(.tags(.typeIs(.ledger)))
    private var metadata: [Tag]
    @Query(.allLedgerItems())
    private var items: [Item]
    @Binding var selectedIdentifier: String
    @State private var newName = ""
    @State private var errorMessage: String?
    @State private var isCompatibilityNoticePresented = false
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Form {
                ledgersSection
                creationSection
            }
            .navigationTitle("Manage Ledgers")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert(
                "Ledger Unavailable",
                isPresented: .init(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
            ) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .alert("Update Every Device", isPresented: $isCompatibilityNoticePresented) {
                Button("All Devices Are Updated", action: createLedger)
                Button("Cancel", role: .cancel) {
                    // Keep the draft name when the notice is cancelled.
                }
            } message: {
                compatibilityNotice
            }
        }
    }

    private var compatibilityNotice: Text {
        Text(
            """
            Before creating an additional ledger, update Incomes to 6.0 or later on every device. \
            Earlier versions combine all ledgers and can remove an item's ledger assignment when editing. \
            If a device cannot be updated, keep using only the default ledger.
            """
        )
    }

    private var ledgersSection: some View {
        Section {
            ForEach(ledgers) { ledger in
                if ledger.id == .default || !ledger.isAvailable {
                    ledgerLabel(ledger)
                } else {
                    NavigationLink {
                        LedgerSettingsView(identifier: ledger.id)
                    } label: {
                        ledgerLabel(ledger)
                    }
                }
            }
        } header: {
            Text("Ledgers")
        } footer: {
            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                Text("Ledgers keep planned income, outgo, and balances separate.")
                Text("All ledgers use the same iCloud account.")
                Text("Widgets and Apple Watch show the default ledger.")
            }
        }
    }

    @ViewBuilder private var creationSection: some View {
        Section {
            if isSubscribeOn {
                TextField("Ledger Name", text: $newName)
                    .disabled(isCreating)
                Button("Create Ledger", systemImage: "plus", action: prepareCreation)
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .disabled(isCreating)
            } else {
                NavigationLink {
                    StoreListView()
                } label: {
                    Label("Subscription", systemImage: "creditcard")
                }
            }
        } header: {
            Text("Create Ledger")
        } footer: {
            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                Text(
                    """
                    A subscription enables creating and editing additional ledgers. \
                    Existing ledgers remain available to view, switch, and export after it ends.
                    """
                )
                Text("Update every device to Incomes 6.0 or later before using additional ledgers.")
            }
        }
    }

    private var ledgers: [LedgerRecord] {
        _ = metadata.map(\.name)
        _ = items.map(\.ledgerIdentifier)
        return (try? LedgerOperations.ledgers(context: context)) ?? []
    }

    private func ledgerLabel(_ ledger: LedgerRecord) -> some View {
        VStack(alignment: .leading) {
            Text(LedgerSelectionTitle.title(
                identifier: ledger.id,
                name: ledger.name,
                names: Dictionary(uniqueKeysWithValues: ledgers.map { ($0.id, $0.name) })
            ))
            if let issue = ledger.issue {
                Text(issue.localizedDescription).foregroundStyle(.red)
            }
        }
    }

    private func prepareCreation() {
        do {
            try LedgerMutationAccess.requireCreation()
            if ledgers.contains(where: { $0.id != .default }) {
                createLedger()
            } else {
                isCompatibilityNoticePresented = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func createLedger() {
        let name = newName
        IncomesMutationWorkflow.performDataMutation(errorMessage: $errorMessage, isProcessing: $isCreating) {
            try LedgerMutationAccess.requireCreation()
            let ledger = try LedgerOperations.create(context: context, name: name)
            selectedIdentifier = ledger.id.rawValue
            newName = ""
        }
    }
}

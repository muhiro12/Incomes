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
    @Query(.tags(.typeIs(.ledger)))
    private var metadata: [Tag]
    @Query(.allLedgerItems())
    private var items: [Item]
    @Binding var selectedIdentifier: String
    @State private var newName = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                introductionSection
                accountsSection
                creationSection
            }
            .navigationTitle("Manage Accounts")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert(
                "Account Unavailable",
                isPresented: .init(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
            ) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var introductionSection: some View {
        Section {
            Text("Accounts keep planned income, outgo, and balances separate.")
            Text("All accounts use the same iCloud account.")
            Text("Update Incomes on every device before using additional accounts.")
            Text("Editing in an earlier version may move entries to the default account.")
        }
    }

    private var accountsSection: some View {
        Section("Accounts") {
            ForEach(accounts) { account in
                if account.id == .default || !account.isAvailable {
                    accountLabel(account)
                } else {
                    NavigationLink {
                        LedgerSettingsView(identifier: account.id)
                    } label: {
                        accountLabel(account)
                    }
                }
            }
        }
    }

    private var creationSection: some View {
        Section {
            TextField("Account Name", text: $newName)
            Button("Create Account", systemImage: "plus", action: createAccount)
                .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .disabled(!isSubscribeOn)
        } footer: {
            VStack(alignment: .leading) {
                Text("Premium enables creating and editing additional accounts.")
                Text("After Premium ends, existing accounts remain available to view, switch, and export.")
            }
        }
    }

    private var accounts: [LedgerRecord] {
        _ = metadata.map(\.name)
        _ = items.map(\.ledgerIdentifier)
        return (try? LedgerOperations.accounts(context: context)) ?? []
    }

    private func accountLabel(_ account: LedgerRecord) -> some View {
        VStack(alignment: .leading) {
            Text(LedgerSelectionTitle.title(
                identifier: account.id,
                name: account.name,
                names: Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0.name) })
            ))
            if let issue = account.issue {
                Text(issue.localizedDescription).foregroundStyle(.red)
            }
        }
    }

    private func createAccount() {
        do {
            try LedgerMutationAccess.requireCreation()
            let account = try LedgerOperations.create(context: context, name: newName)
            selectedIdentifier = account.id.rawValue
            newName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

import CoreData
import MHPlatform
import SwiftData
import SwiftUI

/// Each window keeps its own book selection; switching never rewrites ownership.
struct LedgerWorkspaceView: View {
    @Environment(IncomesRouteInbox.self)
    private var routeInbox

    @Environment(\.modelContext)
    private var context
    @Query(.tags(.typeIs(.ledger)))
    private var metadata: [Tag]
    @Query(.allLedgerItems())
    private var items: [Item]
    @SceneStorage("LedgerWorkspace.selectedIdentifier")
    private var selectedIdentifier = "default"
    @State private var maintenanceError: String?
    @State private var isManagementPresented = false
    @State private var router: MainNavigationRouter = .init()

    private var maintenanceFingerprint: String {
        let rows = items.map { item in
            [
                String(describing: item.persistentModelID), item.utcDate.description, item.content,
                item.income.description, item.outgo.description, item.balance.description,
                (item.tags ?? []).map(\.typeID).sorted().joined(separator: ","), String(item.priority),
                item.repeatID.uuidString
            ].joined(separator: "|")
        }
        return (rows + metadata.map { "\($0.typeID)|\($0.name)" }).joined(separator: ";")
    }

    var body: some View {
        let identifier = LedgerIdentifier(rawValue: selectedIdentifier)
        let result = loadAccounts()
        VStack(spacing: .zero) {
            if router.ledgerIdentifier == identifier {
                bookContent(identifier: identifier, result: result)
            } else {
                ProgressView()
            }
            if let maintenanceError {
                Text(maintenanceError).font(.footnote).foregroundStyle(.red).padding()
            }
        }
        .task(id: maintenanceFingerprint) {
            repairSavedBalances()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
                .receive(on: RunLoop.main)
        ) { _ in
            repairSavedBalances()
        }
        .task(id: selectedIdentifier) {
            guard !Task.isCancelled else {
                return
            }
            let selected = LedgerIdentifier(rawValue: selectedIdentifier)
            if router.ledgerIdentifier != selected {
                router = .init(ledgerIdentifier: selected)
            }
        }
        .mhRouteHandler(routeInbox) { route in
            let owner = MainNavigationOperations.ledgerIdentifier(
                forExternalRoute: route,
                context: context
            )
            if router.ledgerIdentifier != owner {
                router = .init(ledgerIdentifier: owner)
            }
            selectedIdentifier = owner.rawValue
            try router.handleIncomingRoute(route, context: context)
        }
    }

    @ViewBuilder
    private func bookContent(identifier: LedgerIdentifier, result: Result<[LedgerRecord], Error>) -> some View {
        switch result {
        case .success(let accounts):
            LedgerContentView(
                ledgerIdentifier: identifier,
                issue: accounts.first { $0.id == identifier }?.issue,
                accountMenu: LedgerSelectionMenu(
                    accounts: accounts,
                    selectedIdentifier: $selectedIdentifier,
                    manage: presentManagement
                ),
                router: router
            )
            .id(identifier)
            .sheet(isPresented: $isManagementPresented) {
                LedgerManagementView(selectedIdentifier: $selectedIdentifier)
            }

        case .failure(let error):
            ContentUnavailableView(
                "Accounts Unavailable",
                systemImage: "exclamationmark.triangle",
                description: Text(error.localizedDescription)
            )
        }
    }

    private func presentManagement() {
        isManagementPresented = true
    }

    @MainActor
    private func repairSavedBalances() {
        guard !context.hasChanges else {
            return
        }
        do {
            try ItemBalanceOperations.reconcileAndSave(context: context)
            maintenanceError = nil
        } catch {
            maintenanceError = error.localizedDescription
        }
    }

    private func loadAccounts() -> Result<[LedgerRecord], Error> {
        // Live queries invalidate this inventory when synced records or metadata change.
        _ = metadata.map(\.name)
        _ = items.map(\.ledgerIdentifier)
        return Result {
            var accounts = try LedgerOperations.accounts(context: context)
            let selected = LedgerIdentifier(rawValue: selectedIdentifier)
            if !accounts.contains(where: { $0.id == selected }) {
                accounts.append(try LedgerOperations.account(selected, context: context))
            }
            return accounts
        }
    }
}

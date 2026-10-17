import MHPlatform
import SwiftData
import SwiftUI

struct LedgerContentView: View {
    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn
    @LedgerItemQuery private var items: [Item]
    let issue: LedgerError?
    let ownershipIssue: LedgerError?
    let ledgerMenu: LedgerSelectionMenu
    let router: MainNavigationRouter
    let ledgerIdentifier: LedgerIdentifier

    var body: some View {
        let result = balanceResult
        VStack(spacing: .zero) {
            MainNavigationView(
                ledgerIdentifier: ledgerIdentifier,
                ledgerMenu: ledgerMenu,
                router: router
            )
            if case .failure(let error) = result {
                Text(error.localizedDescription).font(.footnote).foregroundStyle(.red).padding()
            } else if let issue {
                Text(issue.localizedDescription).font(.footnote).padding()
            } else if !LedgerAccessOperations.canEdit(ledgerIdentifier, isPremium: isSubscribeOn) {
                Text("Read Only: Premium is required to edit this ledger.").font(.footnote).padding()
            }
        }
        .environment(\.ledgerIdentifier, ledgerIdentifier)
        .environment(\.ledgerBalances, (try? result.get())?.balances ?? [:])
        .environment(\.ledgerIsAvailable, issue == nil)
    }

    private var balanceResult: Result<LedgerBalanceSnapshot, Error> {
        Result {
            if let ownershipIssue {
                throw ownershipIssue
            }
            return try LedgerBalanceOperations.snapshot(items: items, ledgerIdentifier: ledgerIdentifier)
        }
    }

    init(
        ledgerIdentifier: LedgerIdentifier,
        issue: LedgerError?,
        ownershipIssue: LedgerError?,
        ledgerMenu: LedgerSelectionMenu,
        router: MainNavigationRouter
    ) {
        self.ledgerIdentifier = ledgerIdentifier
        self.issue = issue
        self.ownershipIssue = ownershipIssue
        self.ledgerMenu = ledgerMenu
        self.router = router
        _items = .init(.items(.all, ledgerIdentifier: ledgerIdentifier))
    }
}

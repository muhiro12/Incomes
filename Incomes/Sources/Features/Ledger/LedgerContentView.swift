import MHPlatform
import SwiftData
import SwiftUI

struct LedgerContentView: View {
    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn
    @Query private var items: [Item]
    let issue: LedgerError?
    let accountMenu: LedgerSelectionMenu
    let router: MainNavigationRouter
    let ledgerIdentifier: LedgerIdentifier

    var body: some View {
        let result = balanceResult
        VStack(spacing: .zero) {
            MainNavigationView(
                ledgerIdentifier: ledgerIdentifier,
                accountMenu: accountMenu,
                router: router
            )
            if case .failure(let error) = result {
                Text(error.localizedDescription).font(.footnote).foregroundStyle(.red).padding()
            } else if let issue {
                Text(issue.localizedDescription).font(.footnote).padding()
            } else if !LedgerAccessOperations.canEdit(ledgerIdentifier, isPremium: isSubscribeOn) {
                Text("Read Only: Premium is required to edit this account.").font(.footnote).padding()
            }
        }
        .environment(\.ledgerIdentifier, ledgerIdentifier)
        .environment(\.ledgerBalances, (try? result.get())?.balances ?? [:])
        .environment(\.ledgerIsAvailable, issue == nil)
    }

    private var balanceResult: Result<LedgerBalanceSnapshot, Error> {
        Result { try LedgerBalanceOperations.snapshot(items: items, ledgerIdentifier: ledgerIdentifier) }
    }

    init(
        ledgerIdentifier: LedgerIdentifier,
        issue: LedgerError?,
        accountMenu: LedgerSelectionMenu,
        router: MainNavigationRouter
    ) {
        self.ledgerIdentifier = ledgerIdentifier
        self.issue = issue
        self.accountMenu = accountMenu
        self.router = router
        _items = .init(.items(.all, ledgerIdentifier: ledgerIdentifier))
    }
}

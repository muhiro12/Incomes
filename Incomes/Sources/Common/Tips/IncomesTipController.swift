import TipKit

@MainActor
@Observable
final class IncomesTipController {
    private(set) var isConfigured = false

    func configureIfNeeded() throws {
        guard isConfigured == false else {
            return
        }
        try Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
        isConfigured = true
    }

    func refreshHasAnyItems(_ hasAnyItems: Bool) {
        CreateItemTip.hasAnyItems = hasAnyItems
    }

    func donateDidOpenCreateForm() {
        IncomesTipEvents.didOpenCreateForm.sendDonation()
    }

    func donateDidEnableRepeat() {
        IncomesTipEvents.didEnableRepeat.sendDonation()
    }

    func donateDidOpenMonth() {
        IncomesTipEvents.didOpenMonth.sendDonation()
    }

    func donateDidOpenItemDetail() {
        IncomesTipEvents.didOpenItemDetail.sendDonation()
    }

    func donateDidOpenSearch() {
        IncomesTipEvents.didOpenSearch.sendDonation()
    }

    func donateDidApplySearch() {
        IncomesTipEvents.didApplySearch.sendDonation()
    }

    func donateDidOpenSubscription() {
        IncomesTipEvents.didOpenSubscription.sendDonation()
    }

    func donateDidOpenYearlyDuplication() {
        IncomesTipEvents.didOpenYearlyDuplication.sendDonation()
    }

    func resetTips(hasAnyItems: Bool) throws {
        try Tips.resetDatastore()
        refreshHasAnyItems(hasAnyItems)
    }
}

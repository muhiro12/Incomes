import TipKit

enum IncomesTipEvents {
    nonisolated static let didOpenCreateForm = Tips.Event(id: "did-open-create-form")
    nonisolated static let didEnableRepeat = Tips.Event(id: "did-enable-repeat")
    nonisolated static let didOpenMonth = Tips.Event(id: "did-open-month")
    nonisolated static let didOpenItemDetail = Tips.Event(id: "did-open-item-detail")
    nonisolated static let didOpenSearch = Tips.Event(id: "did-open-search")
    nonisolated static let didApplySearch = Tips.Event(id: "did-apply-search")
    nonisolated static let didOpenSubscription = Tips.Event(id: "did-open-subscription")
    nonisolated static let didOpenYearlyDuplication = Tips.Event(id: "did-open-yearly-duplication")
}

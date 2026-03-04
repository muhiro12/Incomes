import AppIntents
import SwiftData
import SwiftUI

struct UpdateItemIntent: AppIntent {
    @Parameter(title: "Item")
    private var item: ItemEntity
    @Parameter(title: "Date", kind: .date)
    private var date: Date
    @Parameter(title: "Content")
    private var content: String
    @Parameter(title: "Income")
    private var income: IntentCurrencyAmount
    @Parameter(title: "Outgo")
    private var outgo: IntentCurrencyAmount
    @Parameter(title: "Category")
    private var category: String
    @Parameter(title: "Priority", default: 0, inclusiveRange: (0, 10))
    private var priority: Int
    @Parameter(title: "Scope", default: .thisItem)
    private var scope: ItemMutationScopeIntentValue

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Update Item", table: "AppIntents")
    static let isDiscoverable = false

    private var formInput: ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: income.amount.description,
            outgoText: outgo.amount.description,
            category: category,
            priorityText: "\(priority)"
        )
    }

    @MainActor
    func perform() throws -> some ReturnsValue<ItemEntity> {
        guard content.isNotEmpty else {
            throw $content.needsValueError()
        }

        let currencyCode = AppStorage(.currencyCode).wrappedValue
        guard income.currencyCode == currencyCode else {
            throw $income.needsDisambiguationError(among: [.init(amount: income.amount, currencyCode: currencyCode)])
        }
        guard outgo.currencyCode == currencyCode else {
            throw $outgo.needsDisambiguationError(among: [.init(amount: outgo.amount, currencyCode: currencyCode)])
        }

        let model = try item.model(in: modelContainer.mainContext)
        try ItemService.update(
            context: modelContainer.mainContext,
            item: model,
            input: formInput,
            scope: scope.scope
        )
        guard let entity = ItemEntity(model) else {
            throw ItemError.entityConversionFailed
        }
        return .result(value: entity)
    }
}

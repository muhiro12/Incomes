import AppIntents
import SwiftData
import SwiftUI

@MainActor
struct UpdateFutureItemsIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, item: ItemEntity, date: Date, content: String, income: Decimal, outgo: Decimal, category: String)
    typealias Output = Void

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

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Update Future Items", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try ItemService.updateFuture(
            context: input.context,
            item: input.item,
            date: input.date,
            content: input.content,
            income: input.income,
            outgo: input.outgo,
            category: input.category
        )
    }

    func perform() throws -> some IntentResult {
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        guard income.currencyCode == currencyCode else {
            throw $income.needsDisambiguationError(among: [.init(amount: income.amount, currencyCode: currencyCode)])
        }
        guard outgo.currencyCode == currencyCode else {
            throw $outgo.needsDisambiguationError(among: [.init(amount: outgo.amount, currencyCode: currencyCode)])
        }
        try Self.perform(
            (
                context: modelContainer.mainContext,
                item: item,
                date: date,
                content: content,
                income: income.amount,
                outgo: outgo.amount,
                category: category
            )
        )
        return .result()
    }
}

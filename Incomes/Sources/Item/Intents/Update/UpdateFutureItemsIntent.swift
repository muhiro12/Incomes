import AppIntents
import SwiftData
import SwiftUI
import SwiftUtilities

struct UpdateFutureItemsIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, item: ItemEntity, date: Date, content: String, income: Decimal, outgo: Decimal, category: String)
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

    static let title: LocalizedStringResource = .init("Update Future Items", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let (container, entity, date, content, income, outgo, category) = input
        guard
            let id = try? PersistentIdentifier(base64Encoded: entity.id),
            let model = try container.mainContext.fetchFirst(
                .items(.idIs(id))
            )
        else {
            throw DebugError.default
        }
        try UpdateRepeatingItemsIntent.perform(
            (
                container: container,
                item: entity,
                date: date,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                descriptor: .items(
                    .repeatIDAndDateIsAfter(
                        repeatID: model.repeatID,
                        date: model.localDate
                    )
                )
            )
        )
    }

    @MainActor
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
                container: modelContainer,
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

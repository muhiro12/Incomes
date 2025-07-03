import AppIntents
import SwiftData
import SwiftUI
import SwiftUtilities

struct UpdateRepeatingItemsIntent: AppIntent, IntentPerformer {
    typealias Input = (
        container: ModelContainer,
        item: ItemEntity,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        descriptor: FetchDescriptor<Item>
    )
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

    static let title: LocalizedStringResource = .init("Update Repeating Items", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let (container, entity, date, content, income, outgo, category, descriptor) = input
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: entity.date,
            to: date
        )
        let repeatID = UUID()
        let items = try container.mainContext.fetch(descriptor)
        try items.forEach { item in
            guard let newDate = Calendar.current.date(byAdding: components, to: item.localDate) else {
                assertionFailure()
                return
            }
            try item.modify(
                date: newDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                repeatID: repeatID
            )
        }
        let calculator = BalanceCalculator()
        try calculator.calculate(in: container.mainContext, for: items)
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
        guard
            let id = try? PersistentIdentifier(base64Encoded: item.id),
            let model = try modelContainer.mainContext.fetchFirst(.items(.idIs(id)))
        else {
            throw DebugError.default
        }
        try Self.perform(
            (
                container: modelContainer,
                item: item,
                date: date,
                content: content,
                income: income.amount,
                outgo: outgo.amount,
                category: category,
                descriptor: .items(.repeatIDIs(model.repeatID))
            )
        )
        return .result()
    }
}

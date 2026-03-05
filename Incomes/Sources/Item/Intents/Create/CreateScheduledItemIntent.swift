import AppIntents
import Foundation
import SwiftData
import SwiftUI

struct CreateScheduledItemIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order
    @Parameter(title: "Content")
    private var content: String // swiftlint:disable:this type_contents_order
    @Parameter(title: "Income")
    private var income: IntentCurrencyAmount // swiftlint:disable:this type_contents_order
    @Parameter(title: "Outgo")
    private var outgo: IntentCurrencyAmount // swiftlint:disable:this type_contents_order
    @Parameter(title: "Category")
    private var category: String // swiftlint:disable:this type_contents_order
    @Parameter(title: "Priority", default: 0, inclusiveRange: (0, 10)) // swiftlint:disable:this no_magic_numbers
    private var priority: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Repeat Months", default: "")
    private var repeatMonths: String // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Create Scheduled Item", table: "AppIntents")
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
        try validateFormInput()

        let currencyCode = AppStorage(.currencyCode).wrappedValue
        if let amount = ItemIntentCurrencyValidator.disambiguationAmount(
            amount: income,
            expectedCurrencyCode: currencyCode
        ) {
            throw $income.needsDisambiguationError(among: [amount])
        }
        if let amount = ItemIntentCurrencyValidator.disambiguationAmount(
            amount: outgo,
            expectedCurrencyCode: currencyCode
        ) {
            throw $outgo.needsDisambiguationError(among: [amount])
        }

        let item = try ItemService.create(
            context: modelContainer.mainContext,
            input: formInput,
            repeatMonthSelections: try parsedRepeatMonthSelections()
        )
        guard let entity = ItemEntity(item) else {
            throw ItemError.entityConversionFailed
        }
        return .result(value: entity)
    }
}

private extension CreateScheduledItemIntent {
    func validateFormInput() throws {
        do {
            try formInput.validate()
        } catch ItemFormInput.ValidationError.contentIsEmpty {
            throw $content.needsValueError()
        } catch ItemFormInput.ValidationError.invalidPriority {
            throw $priority.needsValueError()
        } catch {
            throw error
        }
    }

    func parsedRepeatMonthSelections() throws -> Set<RepeatMonthSelection> {
        do {
            return try RepeatMonthSelectionParser.parse(repeatMonths)
        } catch RepeatMonthSelectionParser.ParserError.invalidToken {
            throw ItemError.invalidRepeatMonthSelections
        }
    }
}

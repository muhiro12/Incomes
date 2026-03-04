import AppIntents
import Foundation
import SwiftData
import SwiftUI

struct CreateScheduledItemIntent: AppIntent {
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
    @Parameter(title: "Repeat Months", default: "")
    private var repeatMonths: String

    @Dependency private var modelContainer: ModelContainer

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
    func parsedRepeatMonthSelections() throws -> Set<RepeatMonthSelection> {
        let trimmedValue = repeatMonths.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedValue.isNotEmpty else {
            return []
        }

        let tokens = trimmedValue
            .split { character in
                character == "," || character.isWhitespace
            }
            .map(String.init)
        var selections = Set<RepeatMonthSelection>()

        for token in tokens {
            let compactValue = token.replacingOccurrences(of: "-", with: "")
            guard compactValue.count == 6,
                  let year = Int(compactValue.prefix(4)),
                  let month = Int(compactValue.suffix(2)),
                  (1...9_999).contains(year),
                  (1...12).contains(month) else {
                throw ItemError.invalidRepeatMonthSelections
            }
            selections.insert(.init(year: year, month: month))
        }

        return selections
    }
}

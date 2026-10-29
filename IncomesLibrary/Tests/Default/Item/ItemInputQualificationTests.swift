import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemInputQualificationTests {
    private let template = """
    # Incomes Item Template
    Template-Version: 1

    ## Date
    - 2026-10-29

    ## Content
    - QA lunch / déjeuner / 昼食
      ## Literal heading
      <b>literal HTML</b> https://example.com

    ## Income
    - 0

    ## Outgo
    - 1234.56

    ## Category
    - Food

    ## Priority
    - 3

    ## Currency
    - JPY
    """

    @Test(arguments: ["en_US", "ja_JP", "fr_FR", "de_DE"], ["12.50", "1.234"])
    func typed_amounts_keep_their_value_after_localized_formatting(_ identifier: String, _ text: String) throws {
        let amount = try #require(Decimal(string: text))
        let input = ItemFormInput(
            date: .now,
            content: "Lunch",
            income: .zero,
            outgo: amount,
            category: "Food",
            locale: .init(identifier: identifier)
        )
        #expect(input.isValid)
        #expect(input.outgo == amount)
        #expect(input.localizedAmounts(locale: .init(identifier: "en_US")).outgo == amount)
        #expect(input.assigning(to: .init()).outgo == amount)
        let update = ItemFormInferenceUpdate(
            date: input.date,
            content: "Lunch",
            income: .zero,
            outgo: amount,
            category: "Food",
            locale: .init(identifier: identifier)
        )
        #expect(update.applied(to: input).outgo == amount)
    }

    @Test
    func templates_cannot_import_text_that_the_writer_refuses() throws {
        let text = template.replacingOccurrences(of: "QA lunch", with: "QA\r lunch")
        #expect(throws: ItemTemplateError.invalidStructure) {
            try ItemTemplateOperations.read(text, ledgerIdentifier: .default, currencyCode: "JPY")
        }
    }

    @available(iOS 26.0, *)
    @Test(arguments: ["20260230", "20261301", "20261000", "2026-10-29", "202610291", "２０２６１０２９"])
    func generated_dates_must_be_real_canonical_days(_ date: String) throws {
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemFormInferenceOperations.validate(
                dateString: date, content: "Lunch", income: .zero, outgo: 100
            )
        }
    }

    @available(iOS 26.0, *)
    @Test(arguments: ["-1", "NaN", "1234567890123456"])
    func generated_amounts_must_follow_the_inference_contract(_ amount: String) throws {
        let value = Decimal(string: amount) ?? .nan
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemFormInferenceOperations.validate(
                dateString: "20261029", content: "Lunch", income: .zero, outgo: value
            )
        }
    }

    @available(iOS 26.0, *)
    @Test
    func generated_values_cannot_mix_income_and_expense_or_omit_content() throws {
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemFormInferenceOperations.validate(
                dateString: "20261029", content: "Lunch", income: 100, outgo: 100
            )
        }
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemFormInferenceOperations.validate(
                dateString: "20261029", content: " \n ", income: .zero, outgo: 100
            )
        }
        try ItemFormInferenceOperations.validate(
            dateString: "20280229", content: "Lunch", income: .zero, outgo: 100
        )
    }

    @available(iOS 26.0, *)
    @Test
    func unknown_amounts_remain_zero_drafts_with_explicit_review_metadata() throws {
        try ItemFormInferenceOperations.validate(dateString: "", content: "Rent", income: nil, outgo: nil)
        let original = try ItemTemplateOperations.read(template, ledgerIdentifier: .default, currencyCode: "JPY")
        let update = ItemFormInferenceUpdate(dateString: "", content: "Rent", income: nil, outgo: nil, category: "Rent")
        let draft = update.applied(to: original)
        #expect(update.hasUnspecifiedAmount)
        #expect(update.hasUnspecifiedDate)
        #expect(draft.isValid)
        #expect(draft.income == .zero && draft.outgo == .zero)
        #expect(draft.date == original.date)
        #expect(draft.priority == original.priority)
        #expect(draft.ledgerIdentifier == original.ledgerIdentifier)
        let knownZero = ItemFormInferenceUpdate(
            dateString: "20261029", content: "Free", income: .zero, outgo: .zero, category: ""
        )
        #expect(!knownZero.hasUnspecifiedAmount && !knownZero.hasUnspecifiedDate)
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemFormInferenceOperations.validate(dateString: "20261029", content: "Rent", income: nil, outgo: 0)
        }
    }

    @available(iOS 26.0, *)
    @Test(arguments: ["inference", "template"], [false, true])
    @MainActor
    func both_paths_preserve_financial_values_through_save_reopen_and_export(
        path: String,
        additionalLedger: Bool
    ) throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        let url = directory.appendingPathComponent("InputQualification.sqlite")
        let original = try autoreleasepool {
            let container = try makeContainer(url)
            let context = container.mainContext
            let ledgerIdentifier = try additionalLedger
                ? LedgerOperations.create(context: context, name: "QA destination").id
                : LedgerIdentifier.default
            let expected = try ItemTemplateOperations.read(
                template, ledgerIdentifier: ledgerIdentifier, currencyCode: "JPY"
            )
            let input = try proposal(path: path, expected: expected)
            #expect(context.hasChanges == false)
            let item = try ItemCreationOperations.createAndSaveWithOutcome(
                context: context, input: input, repeatCount: 1
            ).value
            #expect(item.balance == -expected.outgo)
            return ItemExportOperations.fileItems(items: [item])
        }
        let reopened = try makeContainer(url)
        let saved = try reopened.mainContext.fetch(.allLedgerItems())
        #expect(saved.count == 1)
        #expect(ItemExportOperations.fileItems(items: saved) == original)
        let item = try #require(saved.first)
        let exported = try ItemTemplateOperations.text(for: item, currencyCode: "JPY")
        let imported = try ItemTemplateOperations.read(
            exported, ledgerIdentifier: item.ledgerIdentifier, currencyCode: "JPY"
        )
        let expectedContent = "QA lunch / déjeuner / 昼食\n## Literal heading\n"
            + "<b>literal HTML</b> https://example.com"
        #expect(imported.content == expectedContent)
        #expect(imported.income == .zero)
        #expect(imported.outgo == Decimal(string: "1234.56"))
        #expect(imported.priority == 3)
        #expect(imported.category == "Food")
        #expect(imported.date.stringValueWithoutLocale(.yyyyMMdd) == "20261029")
        #expect(reopened.mainContext.hasChanges == false)
    }

    private func makeContainer(_ url: URL) throws -> ModelContainer {
        try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
    }

    @available(iOS 26.0, *)
    private func proposal(path: String, expected: ItemFormInput) throws -> ItemFormInput {
        guard path == "inference" else {
            return expected
        }
        try ItemFormInferenceOperations.validate(
            dateString: "20261029", content: expected.content, income: .zero, outgo: expected.outgo
        )
        return ItemFormInferenceUpdate(
            dateString: "20261029",
            content: expected.content,
            income: .zero,
            outgo: expected.outgo,
            category: "Food"
        ).applied(to: expected)
    }
}

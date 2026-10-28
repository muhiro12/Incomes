import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemTemplateOperationsTests {
    private let example = """
    # Incomes Item Template
    Template-Version: 1

    ## Date
    - 2026-10-28

    ## Content
    - 昼食 / déjeuner
      ## This is literal content
      <script>do not run</script> https://example.com
      EMPTY_LINE
      - Keep this bullet as text

    ## Income
    - 0

    ## Outgo
    - 1234.56

    ## Category
    - Food

    ## Priority
    - 2

    ## Currency
    - JPY
    """.replacingOccurrences(of: "  EMPTY_LINE", with: "  ")

    @Test
    func reads_literal_values_without_inference_or_store_changes() throws {
        let input = try read(example)
        let expectedContent = [
            "昼食 / déjeuner", "## This is literal content",
            "<script>do not run</script> https://example.com", "", "- Keep this bullet as text"
        ].joined(separator: "\n")
        #expect(input.content == expectedContent)
        #expect(input.income == .zero)
        #expect(input.outgo == Decimal(string: "1234.56"))
        #expect(input.priority == 2)
        #expect(input.category == "Food")
        #expect(input.date.stringValueWithoutLocale(.yyyyMMdd) == "20261028")
    }

    @Test
    func section_order_and_outer_fence_do_not_change_values() throws {
        let reordered = example.replacingOccurrences(of: "\n## Currency\n- JPY", with: "")
            .replacingOccurrences(of: "Template-Version: 1", with: "Template-Version: 1\n\n## Currency\n- JPY")
        #expect(try read("```markdown\n" + reordered + "\n```\n") == read(example))
        #expect(try read(example.replacingOccurrences(of: "\n", with: "\r\n")) == read(example))
    }

    @Test(arguments: ["", "unknown", "1,234", "1.234,56", "1e3", "NaN", "12345678901234567890"])
    func refuses_blank_ambiguous_or_inexact_amounts(_ value: String) throws {
        let text = example.replacingOccurrences(of: "- 1234.56", with: "- " + value)
        #expect(throws: ItemTemplateError.invalidField("Outgo")) {
            try read(text)
        }
    }

    @Test(arguments: ["2026-02-30", "tomorrow", "2026-2-3", "", "2026-10-28T00:00:00Z"])
    func refuses_missing_or_ambiguous_days(_ value: String) throws {
        #expect(throws: ItemTemplateError.invalidField("Date")) {
            try read(example.replacingOccurrences(of: "2026-10-28", with: value))
        }
    }

    @Test
    func refuses_unknown_missing_duplicate_and_unsupported_sections() throws {
        #expect(throws: ItemTemplateError.unknownField("Ledger")) {
            try read(example + "\n## Ledger\n- Other")
        }
        #expect(throws: ItemTemplateError.duplicateField("Income")) {
            try read(example + "\n## Income\n- 10")
        }
        #expect(throws: ItemTemplateError.missingField("Currency")) {
            try read(example.replacingOccurrences(of: "\n## Currency\n- JPY", with: ""))
        }
        #expect(throws: ItemTemplateError.unsupportedVersion) {
            try read(example.replacingOccurrences(of: "Template-Version: 1", with: "Template-Version: 2"))
        }
    }

    @Test(arguments: ["```", "```\n```", "Some AI explanation\n", "# Other format", ""])
    func malformed_input_never_becomes_an_inference_request(_ text: String) throws {
        #expect(throws: ItemTemplateError.invalidStructure) {
            try read(text)
        }
    }

    @Test
    func bounds_input_and_refuses_currency_changes() throws {
        #expect(throws: ItemTemplateError.tooLarge) {
            try read(String(repeating: "x", count: 16_385))
        }
        #expect(throws: ItemTemplateError.tooLarge) {
            try read(String(repeating: "\n", count: 513))
        }
        #expect(throws: ItemTemplateError.currencyMismatch) {
            try read(example.replacingOccurrences(of: "- JPY", with: "- USD"))
        }
        #expect(throws: ItemTemplateError.currencyRequired) {
            try ItemTemplateOperations.read(example, ledgerIdentifier: .default, currencyCode: "")
        }
    }

    @Test
    func an_unfilled_template_cannot_silently_supply_financial_facts() throws {
        let blank = try ItemTemplateOperations.blankTemplate(currencyCode: "JPY")
        #expect(throws: ItemTemplateError.invalidField("Date")) {
            try read(blank)
        }
        let prompt = try ItemTemplateOperations.promptAndTemplate(currencyCode: "JPY")
        #expect(prompt.contains(blank))
    }

    @Test
    @MainActor
    func export_preserves_supported_values_and_import_binds_the_chosen_ledger() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let original = try read(example)
        let item = try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: original,
            repeatCount: 1
        ).value
        let dataBeforeReading = try ItemExportOperations.prepareFile(context: context).items
        let text = try ItemTemplateOperations.text(for: item, currencyCode: "JPY")
        let imported = try read(text)
        #expect(imported == original)
        #expect(!text.contains("repeatID"))
        #expect(!text.contains("Balance"))
        #expect(!text.contains("Ledger"))
        #expect(try ItemTemplateOperations.requiresCategoryConfirmation(context: context, input: imported) == false)
        #expect(try ItemExportOperations.prepareFile(context: context).items == dataBeforeReading)
        #expect(context.hasChanges == false)
        let destination = try LedgerOperations.create(context: context, name: "Other book")
        let otherInput = try ItemTemplateOperations.read(text, ledgerIdentifier: destination.id, currencyCode: "JPY")
        #expect(otherInput.ledgerIdentifier == destination.id)
        #expect(otherInput.content == original.content)
    }

    @Test
    func edited_source_form_ledger_or_currency_invalidates_a_review() throws {
        let input = try read(example)
        let review = ItemTemplateReview(input: input, originalInput: input, sourceText: example, currencyCode: "JPY")
        #expect(review.isCurrent(input: input, sourceText: example, currencyCode: "JPY"))
        #expect(!review.isCurrent(input: input, sourceText: example + "\n", currencyCode: "JPY"))
        #expect(!review.isCurrent(input: input, sourceText: example, currencyCode: "USD"))
        #expect(!review.isCurrent(input: input.assigning(to: .init()), sourceText: example, currencyCode: "JPY"))
        let changedInput = try read(example.replacingOccurrences(of: "- 1234.56", with: "- 99"))
        #expect(!review.isCurrent(input: changedInput, sourceText: example, currencyCode: "JPY"))
    }

    @Test
    @MainActor
    func new_category_review_does_not_create_tags() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let input = try read(example)
        #expect(try ItemTemplateOperations.requiresCategoryConfirmation(context: context, input: input))
        #expect(try context.fetchCount(FetchDescriptor<IncomesLibrary.Tag>()) == .zero)
        #expect(context.hasChanges == false)
        #expect(throws: ItemTemplateError.invalidField("Outgo")) {
            try read(example.replacingOccurrences(of: "- 1234.56", with: "- unknown"))
        }
        #expect(try context.fetchCount(FetchDescriptor<Item>()) == .zero)
    }

    private func read(_ text: String) throws -> ItemFormInput {
        try ItemTemplateOperations.read(text, ledgerIdentifier: .default, currencyCode: "JPY")
    }
}

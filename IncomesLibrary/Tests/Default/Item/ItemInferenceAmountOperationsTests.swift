import Foundation
import IncomesLibrary
import Testing

struct ItemInferenceAmountOperationsTests {
    @available(iOS 26.0, *)
    @Test(arguments: [
        ("1,234.56", "en_US", "1234.56"),
        ("1,234.567", "ja_JP", "1234.567"),
        ("1\u{202F}234,56", "fr_FR", "1234.56"),
        ("1234,567", "es_ES", "1234.567"),
        ("1.234567", "en_US", "1.234567"),
        ("0", "ja_JP", "0")
    ])
    func amounts_preserve_source_decimal_digits(expression: String, locale: String, expected: String) throws {
        let amount = try ItemInferenceAmountOperations.amount(
            expression: expression, sourceText: "Paid: \(expression)", locale: .init(identifier: locale)
        )
        #expect(amount == Decimal(string: expected))
    }

    @available(iOS 26.0, *)
    @Test(arguments: [
        ("200", "Paid 1,200"),
        ("234", "Paid 1 234"),
        ("12", "Paid 12.50"),
        ("0", "Paid 1200"),
        ("1234.55", "Paid 1,234.56"),
        ("999", "Paid 100"),
        ("3", "支払額 3万円"),
        ("-100", "Refund -100"),
        ("-100", "Paid 100"),
        ("100", "Refund -100"),
        ("1234567890123456", "Paid 1234567890123456")
    ])
    func rewritten_partial_negative_or_inexact_amounts_are_rejected(expression: String, source: String) {
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemInferenceAmountOperations.amount(
                expression: expression, sourceText: source, locale: .init(identifier: "en_US")
            )
        }
    }

    @available(iOS 26.0, *)
    @Test
    func absent_amount_stays_distinct_from_explicit_zero() throws {
        #expect(try ItemInferenceAmountOperations.amount(
            expression: "", sourceText: "No amount given", locale: .init(identifier: "en_US")
        ) == nil)
        #expect(try ItemInferenceAmountOperations.amount(
            expression: "0", sourceText: "Price: 0", locale: .init(identifier: "en_US")
        ) == .zero)
    }

    @available(iOS 26.0, *)
    @Test
    func grouping_changes_preserve_only_the_exact_source_value() throws {
        #expect(try ItemInferenceAmountOperations.amount(
            expression: "1234.56",
            sourceText: "Paid 1,234.56",
            locale: .init(identifier: "en_US")
        ) == Decimal(string: "1234.56"))
        #expect(try ItemInferenceAmountOperations.amount(
            expression: "1234.56",
            sourceText: "Payé 1\u{202F}234,56",
            locale: .init(identifier: "fr_FR")
        ) == Decimal(string: "1234.56"))
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemInferenceAmountOperations.amount(
                expression: "1.234",
                sourceText: "1234 y 1,234",
                locale: .init(identifier: "es_ES")
            )
        }
    }

    @available(iOS 26.0, *)
    @Test
    func missing_separators_are_restored_only_from_one_complete_source_value() throws {
        #expect(try ItemInferenceAmountOperations.amount(
            expression: "1234567",
            sourceText: "Dépenses : 1\u{202F}234,567",
            locale: .init(identifier: "fr_FR")
        ) == Decimal(string: "1234.567"))
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemInferenceAmountOperations.amount(
                expression: "1250",
                sourceText: "Total 12.50; reference 1250",
                locale: .init(identifier: "en_US")
            )
        }
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemInferenceAmountOperations.amount(
                expression: "1e3",
                sourceText: "Total 13",
                locale: .init(identifier: "en_US")
            )
        }
        #expect(try ItemInferenceAmountOperations.amount(
            expression: "12.50",
            sourceText: "Total 12.50; reference 1250",
            locale: .init(identifier: "en_US")
        ) == Decimal(string: "12.50"))
    }

    @available(iOS 26.0, *)
    @Test(arguments: [("540円", "ja_JP", "540"), ("$12.50", "en_US", "12.50"), ("12,50 EUR", "fr_FR", "12.50")])
    func copied_currency_labels_do_not_change_the_amount(expression: String, locale: String, expected: String) throws {
        #expect(try ItemInferenceAmountOperations.amount(
            expression: expression,
            sourceText: "Total: \(expression)",
            locale: .init(identifier: locale)
        ) == Decimal(string: expected))
        #expect(throws: ItemInferenceError.invalidResult) {
            try ItemInferenceAmountOperations.amount(
                expression: "3万円",
                sourceText: "支出 3万円",
                locale: .init(identifier: "ja_JP")
            )
        }
    }
}

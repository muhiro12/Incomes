import Foundation
import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct ItemContentOperationsTests {
    @Test
    func copying_preserves_literal_content_and_exact_values_without_private_metadata() throws {
        let container = try ModelContainerFactory.make(configuration: .init(isStoredInMemoryOnly: true))
        let context = container.mainContext
        let ledger = try LedgerOperations.create(context: context, name: "Private ledger")
        let item = try makeItem(context: context, ledgerIdentifier: ledger.id)
        let before = ItemExportOperations.fileItems(items: [item])

        let text = ItemContentOperations.text(for: item, currencyCode: "JPY", locale: .init(identifier: "en_US"))

        #expect(text == """
        Date: Oct 29, 2026
        Lunch / déjeuner / 昼食
        ## Literal heading
        <b>literal HTML</b> https://example.com
        Income: 0
        Outgo: 1,234.567
        Category: Food
        Currency: JPY
        """)
        #expect(ItemExportOperations.fileItems(items: [item]) == before)
        #expect(!context.hasChanges)
    }

    @Test
    func copying_without_a_currency_still_provides_content_and_does_not_guess_one() throws {
        let container = try ModelContainerFactory.make(configuration: .init(isStoredInMemoryOnly: true))
        let item = try makeItem(context: container.mainContext)
        let text = ItemContentOperations.text(for: item, currencyCode: "", locale: .init(identifier: "en_US"))
        #expect(text.contains("Outgo: 1,234.567"))
        #expect(!text.contains("Currency:"))
        #expect(!text.contains("USD"))
        #expect(!text.contains("JPY"))
    }

    @Test
    func copying_localizes_labels_and_decimal_separators() throws {
        let container = try ModelContainerFactory.make(configuration: .init(isStoredInMemoryOnly: true))
        let item = try makeItem(context: container.mainContext)
        let japanese = ItemContentOperations.text(for: item, currencyCode: "JPY", locale: .init(identifier: "ja_JP"))
        #expect(japanese.contains("日付: 2026年10月29日"))
        #expect(japanese.contains("支出: 1,234.567"))
        #expect(japanese.contains("カテゴリー: Food"))
        let french = ItemContentOperations.text(for: item, currencyCode: "EUR", locale: .init(identifier: "fr_FR"))
        #expect(french.contains("1\u{202F}234,567"))
        #expect(french.contains("Devise : EUR"))
    }

    private func makeItem(
        context: ModelContext,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> Item {
        let date = try #require(DateFormatter.fixed(.yyyyMMdd).date(from: "20261029"))
        let amount = try #require(Decimal(string: "1234.567"))
        return try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: .init(
                date: date,
                content: "Lunch / déjeuner / 昼食\n## Literal heading\n<b>literal HTML</b> https://example.com",
                income: .zero,
                outgo: amount,
                category: "Food",
                priority: 7,
                ledgerIdentifier: ledgerIdentifier
            ),
            repeatCount: 1
        ).value
    }
}

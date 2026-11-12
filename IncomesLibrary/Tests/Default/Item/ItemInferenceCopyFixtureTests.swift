import Foundation
import IncomesLibrary
import Testing

@MainActor
struct ItemInferenceCopyFixtureTests {
    private struct Expected: Decodable {
        let date: String
        let content: String
        let income: String
        let outgo: String
        let category: String
    }

    private struct Fixture: Decodable {
        let id: String
        let locale: String
        let currency: String
        let text: String
        let expected: Expected
    }

    @Test
    func evaluation_sources_match_actual_copied_items() throws {
        let url = try #require(Bundle.module.url(
            forResource: "ItemInferenceCopyCases",
            withExtension: "json",
            subdirectory: "Fixtures"
        ))
        let fixtures = try JSONDecoder().decode([Fixture].self, from: Data(contentsOf: url))
        let container = try ModelContainerFactory.make(configuration: .init(isStoredInMemoryOnly: true))
        for fixture in fixtures {
            let expected = fixture.expected
            let date = try #require(DateFormatter.fixed(.yyyyMMdd).date(from: expected.date))
            let income = try #require(Decimal(string: expected.income))
            let outgo = try #require(Decimal(string: expected.outgo))
            let item = try ItemCreationOperations.createAndSaveWithOutcome(
                context: container.mainContext,
                input: .init(
                    date: date,
                    content: expected.content,
                    income: income,
                    outgo: outgo,
                    category: expected.category
                ),
                repeatCount: 1
            ).value

            #expect(ItemContentOperations.text(
                for: item,
                currencyCode: fixture.currency,
                locale: .init(identifier: fixture.locale)
            ) == fixture.text, "\(fixture.id)")
        }
    }
}

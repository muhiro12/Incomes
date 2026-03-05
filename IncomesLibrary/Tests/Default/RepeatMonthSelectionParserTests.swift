import Foundation
@testable import IncomesLibrary
import Testing

struct RepeatMonthSelectionParserTests {
    @Test
    func parse_accepts_commas_spaces_and_hyphens() throws {
        let selections = try RepeatMonthSelectionParser.parse(
            "202501, 2025-02 202503"
        )

        #expect(selections.count == 3)
        #expect(selections.contains(.init(year: 2_025, month: 1)))
        #expect(selections.contains(.init(year: 2_025, month: 2)))
        #expect(selections.contains(.init(year: 2_025, month: 3)))
    }

    @Test
    func parse_returns_empty_for_blank_text() throws {
        let selections = try RepeatMonthSelectionParser.parse("   ")
        #expect(selections.isEmpty)
    }

    @Test
    func parse_throws_for_invalid_token() {
        #expect(throws: RepeatMonthSelectionParser.ParserError.self) {
            _ = try RepeatMonthSelectionParser.parse("2025AA")
        }
    }
}

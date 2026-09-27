import Foundation
@testable import IncomesLibrary
import Testing

struct NaturalLanguageSearchAmountTests {
    private struct AmountCase {
        let amounts: [NaturalLanguageSearchExtraction.AmountCondition]
        let request: String
        let error: NaturalLanguageSearchError
    }

    private let calendar = Self.tokyoCalendar
    private let currentDate = isoDate("2026-09-15T03:00:00Z")

    @Test("An exact amount becomes equal inclusive bounds")
    func exact_amount_is_inclusive_on_both_sides() throws {
        let conditions = try conditions(
            .init(amounts: [
                .init(target: .outgo, comparison: .exactly, amount: "1200")
            ]),
            request: "outgo of 1,200"
        )

        #expect(conditions.outgo == .init(minimum: 1_200, maximum: 1_200))
    }

    @Test("Missing, malformed, and overprecise amounts fail")
    func invalid_amounts_fail() {
        let overprecise = "0." + String(
            repeating: "1",
            count: AmountPrecision.maximumSignificantDigits + 1
        )
        let cases: [AmountCase] = [
            .init(
                amounts: [.init(target: .income, comparison: .atLeast, amount: "")],
                request: "income",
                error: .missingAmount(.income)
            ),
            .init(
                amounts: [.init(target: .outgo, comparison: .atMost, amount: " ")],
                request: "outgo",
                error: .missingAmount(.outgo)
            ),
            .init(
                amounts: [.init(target: .income, comparison: .atLeast, amount: "about 100")],
                request: "100",
                error: .invalidAmount(.income)
            ),
            .init(
                amounts: [.init(target: .outgo, comparison: .atMost, amount: "5000円")],
                request: "5000",
                error: .invalidAmount(.outgo)
            ),
            .init(
                amounts: [.init(target: .outgo, comparison: .atLeast, amount: overprecise)],
                request: overprecise,
                error: .invalidAmount(.outgo)
            ),
            .init(
                amounts: [.init(target: .income, comparison: .atLeast, amount: "1e999")],
                request: "1",
                error: .invalidAmount(.income)
            )
        ]

        for amountCase in cases {
            #expect(throws: amountCase.error) {
                try conditions(.init(amounts: amountCase.amounts), request: amountCase.request)
            }
        }
    }

    @Test("Inverted amount ranges fail")
    func inverted_amount_ranges_fail() {
        let cases: [AmountCase] = [
            .init(
                amounts: [
                    .init(target: .income, comparison: .atLeast, amount: "500"),
                    .init(target: .income, comparison: .atMost, amount: "100")
                ],
                request: "income 500 100",
                error: .invertedRange(.income)
            ),
            .init(
                amounts: [
                    .init(target: .outgo, comparison: .atLeast, amount: "-1"),
                    .init(target: .outgo, comparison: .atMost, amount: "-2")
                ],
                request: "outgo -1 -2",
                error: .invertedRange(.outgo)
            )
        ]

        for amountCase in cases {
            #expect(throws: amountCase.error) {
                try conditions(.init(amounts: amountCase.amounts), request: amountCase.request)
            }
        }
    }

    @Test("Strict, conflicting, and duplicate amount comparisons fail")
    func unsupported_amount_comparisons_fail() {
        let cases: [AmountCase] = [
            .init(
                amounts: [.init(target: .outgo, comparison: .moreThan, amount: "10000")],
                request: "outgo 10000",
                error: .strictComparison(.outgo)
            ),
            .init(
                amounts: [.init(target: .income, comparison: .lessThan, amount: "300")],
                request: "income 300",
                error: .strictComparison(.income)
            ),
            .init(
                amounts: [
                    .init(target: .outgo, comparison: .atLeast, amount: "100"),
                    .init(target: .outgo, comparison: .atLeast, amount: "200")
                ],
                request: "outgo 100 200",
                error: .conflictingAmounts(.outgo)
            ),
            .init(
                amounts: [
                    .init(target: .income, comparison: .exactly, amount: "100"),
                    .init(target: .income, comparison: .atMost, amount: "200")
                ],
                request: "income 100 200",
                error: .conflictingAmounts(.income)
            )
        ]

        for amountCase in cases {
            #expect(throws: amountCase.error) {
                try conditions(.init(amounts: amountCase.amounts), request: amountCase.request)
            }
        }
    }
}

private extension NaturalLanguageSearchAmountTests {
    static var tokyoCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        guard let timeZone = TimeZone(identifier: "Asia/Tokyo") else {
            preconditionFailure("Missing Asia/Tokyo time zone")
        }
        calendar.timeZone = timeZone
        return calendar
    }

    func conditions(
        _ extraction: NaturalLanguageSearchExtraction,
        request: String
    ) throws -> ItemSearchConditions {
        try NaturalLanguageSearchOperations.conditions(
            from: extraction,
            request: request,
            currentDate: currentDate,
            calendar: calendar
        )
    }
}

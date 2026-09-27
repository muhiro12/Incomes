import Foundation
@testable import IncomesLibrary
import Testing

struct NaturalLanguageSearchGroundingTests {
    private let calendar = Self.tokyoCalendar
    private let currentDate = isoDate("2026-09-15T03:00:00Z")

    // MARK: - Accepted

    @Test("Written numbers ground years, months, and amounts")
    func written_numbers_ground_conditions() throws {
        let conditions = try conditions(
            .init(
                year: 2_025,
                month: 12,
                content: "家賃",
                amounts: [
                    .init(target: .outgo, comparison: .atMost, amount: "80000")
                ]
            ),
            request: "2025年12月の家賃で支出が80,000円以下"
        )

        #expect(conditions == .init(
            period: .init(year: 2_025, month: 12),
            content: "家賃",
            outgo: .init(minimum: nil, maximum: 80_000)
        ))
    }

    @Test("Full-width digits and signs ground amounts")
    func full_width_numbers_ground_amounts() throws {
        let conditions = try conditions(
            .init(amounts: [
                .init(target: .income, comparison: .atLeast, amount: "-300"),
                .init(target: .income, comparison: .atMost, amount: "1000")
            ]),
            request: "収入が－３００以上１０００以下"
        )

        #expect(conditions.income == .init(minimum: -300, maximum: 1_000))
    }

    @Test("Longer relative month words are not read as shorter ones")
    func relative_month_words_prefer_longest_phrase() throws {
        let conditions = try conditions(
            .init(relativeMonthOffset: 2, content: "保険"),
            request: "再来月の保険"
        )

        #expect(conditions.period == .init(year: 2_026, month: 11))
        #expect(throws: NaturalLanguageSearchError.ungroundedMonth) {
            try self.conditions(
                .init(relativeMonthOffset: 1, content: "保険"),
                request: "再来月の保険"
            )
        }
    }

    @Test("Numbers inside literal content are used by the content")
    func content_numbers_are_used() throws {
        let conditions = try conditions(
            .init(relativeMonthOffset: -1, content: "7-Eleven"),
            request: "7-Eleven last month"
        )

        #expect(conditions.content == "7-Eleven")
    }

    // MARK: - Fail closed

    @Test("A stated month that the extraction omits fails")
    func omitted_months_fail() {
        let cases: [(NaturalLanguageSearchExtraction, String)] = [
            (.init(content: "rent"), "rent next month"),
            (.init(content: "給料"), "先月の給料"),
            (.init(content: "electricity"), "electricity in March"),
            (.init(year: 2_025, month: 11, content: "rent"), "rent in December 2025")
        ]

        for (extraction, request) in cases {
            #expect(throws: NaturalLanguageSearchError.unusedMonth) {
                try conditions(extraction, request: request)
            }
        }
    }

    @Test("A month or year the request does not state fails")
    func ungrounded_months_fail() {
        let cases: [(NaturalLanguageSearchExtraction, String)] = [
            (.init(relativeMonthOffset: 1, content: "家賃"), "1月の家賃"),
            (.init(relativeMonthOffset: -1, content: "rent"), "rent next month"),
            (.init(month: 9, content: "rent"), "rent"),
            (.init(year: 2_025, month: 3, content: "電気代"), "2026年3月の電気代")
        ]

        for (extraction, request) in cases {
            #expect(throws: NaturalLanguageSearchError.ungroundedMonth) {
                try conditions(extraction, request: request)
            }
        }
    }

    @Test("An amount the request does not write as a plain number fails")
    func ungrounded_amounts_fail() {
        let cases: [(NaturalLanguageSearchExtraction.AmountCondition, String)] = [
            (.init(target: .outgo, comparison: .atLeast, amount: "0"), "rent"),
            (.init(target: .income, comparison: .atLeast, amount: "30"), "収入が30万円以上"),
            (.init(target: .income, comparison: .atLeast, amount: "300000"), "収入が30万円以上"),
            (.init(target: .outgo, comparison: .atLeast, amount: "13"), "13月の家賃"),
            (.init(target: .outgo, comparison: .atMost, amount: "500"), "outgo at most -500")
        ]

        for (amount, request) in cases {
            #expect(throws: NaturalLanguageSearchError.ungroundedAmount(amount.target)) {
                try conditions(.init(amounts: [amount]), request: request)
            }
        }
    }

    @Test("Written numbers that no condition uses fail")
    func unused_numbers_fail() {
        #expect(throws: NaturalLanguageSearchError.unusedNumbers(["5"])) {
            try conditions(
                .init(month: 4, content: "家賃"),
                request: "4月5日の家賃"
            )
        }
        #expect(throws: NaturalLanguageSearchError.unusedNumbers(["30"])) {
            try conditions(
                .init(content: "収入"),
                request: "収入が30万円以上"
            )
        }
        #expect(throws: NaturalLanguageSearchError.unusedNumbers(["0"])) {
            try conditions(
                .init(amounts: [
                    .init(target: .outgo, comparison: .atLeast, amount: "-500")
                ]),
                request: "支出が-500以上0以下"
            )
        }
    }

    @Test("Content that repeats another condition's number fails")
    func overlapping_content_fails() {
        #expect(throws: NaturalLanguageSearchError.overlappingContent) {
            try conditions(
                .init(
                    content: "支出が-500以上0以下",
                    amounts: [
                        .init(target: .outgo, comparison: .atLeast, amount: "-500")
                    ]
                ),
                request: "支出が-500以上0以下"
            )
        }
    }
}

private extension NaturalLanguageSearchGroundingTests {
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

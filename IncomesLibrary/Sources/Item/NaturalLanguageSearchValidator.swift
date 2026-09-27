import Foundation

/// Turns unvalidated natural-language search extractions into search conditions.
///
/// Invalid field values stop interpretation instead of widening its conditions.
/// Validation cannot prove the model preserved every part of the request; the
/// person reviews the interpreted conditions before querying.
enum NaturalLanguageSearchValidator {
    static let maximumRequestLength = 200
    static let supportedYears = 1_900...9_999
    static let supportedMonths = 1...12
    private static let maximumMonthOffset = 1_200
    static let supportedRelativeMonthOffsets = -maximumMonthOffset...maximumMonthOffset

    private static let monthsPerYear = 12
    private static let groundingOptions: String.CompareOptions = [
        .caseInsensitive,
        .diacriticInsensitive,
        .widthInsensitive
    ]
    // Read-only search never changes data, but a request that asks for a
    // change is refused before generation so it cannot look like it ran.
    private static let mutationWords: Set<String> = [
        "add",
        "change",
        "copy",
        "create",
        "delete",
        "duplicate",
        "edit",
        "erase",
        "insert",
        "modify",
        "move",
        "remove",
        "rename",
        "update"
    ]
    // Results are limited and never complete ledger totals, so calculation
    // requests are refused before generation instead of listing items.
    private static let calculationWords: Set<String> = [
        "average",
        "averages",
        "sum",
        "total",
        "totals"
    ]
    private static let calculationPhrases = [
        "how much",
        "いくら",
        "合計",
        "平均",
        "総額",
        "集計"
    ]
    private static let mutationPhrases = [
        "コピー",
        "作成",
        "削除",
        "変更",
        "移動",
        "追加",
        "消去",
        "消して",
        "登録",
        "編集",
        "複製",
        "書き換え"
    ]

    static func validatedRequest(_ request: String) throws -> String {
        let trimmedRequest = request.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedRequest.isEmpty else {
            throw NaturalLanguageSearchError.emptyRequest
        }
        guard trimmedRequest.count <= maximumRequestLength else {
            throw NaturalLanguageSearchError.requestTooLong
        }
        guard !asksToChangeData(trimmedRequest) else {
            throw NaturalLanguageSearchError.unsupportedAction
        }
        guard !asksToCalculate(trimmedRequest) else {
            throw NaturalLanguageSearchError.unsupportedCalculation
        }
        let unsupportedTerms = NaturalLanguageSearchUnsupportedTerms.find(in: trimmedRequest)
        guard unsupportedTerms.isEmpty else {
            throw NaturalLanguageSearchError.unsupportedTerms(unsupportedTerms)
        }
        return trimmedRequest
    }

    static func conditions(
        from extraction: NaturalLanguageSearchExtraction,
        request: String,
        currentDate: Date,
        calendar: Calendar
    ) throws -> ItemSearchConditions {
        let validRequest = try validatedRequest(request)

        let unsupportedTerms = extraction.unsupportedTerms.compactMap(nonEmptyText)
        guard unsupportedTerms.isEmpty else {
            throw NaturalLanguageSearchError.unsupportedTerms(unsupportedTerms)
        }

        var grounding = NaturalLanguageSearchGrounding(request: validRequest)
        let period = try period(
            from: extraction,
            currentDate: currentDate,
            calendar: calendar,
            grounding: &grounding
        )
        let income = try amountRange(
            extraction.amounts,
            target: .income,
            grounding: &grounding
        )
        let outgo = try amountRange(
            extraction.amounts,
            target: .outgo,
            grounding: &grounding
        )
        let content = try content(
            extraction.content,
            request: validRequest
        )
        if let content {
            guard grounding.useNumbers(inContent: content) else {
                throw NaturalLanguageSearchError.overlappingContent
            }
        }
        let unusedNumbers = grounding.unusedNumberTexts
        guard unusedNumbers.isEmpty else {
            throw NaturalLanguageSearchError.unusedNumbers(unusedNumbers)
        }

        let conditions = ItemSearchConditions(
            period: period,
            content: content,
            income: income,
            outgo: outgo
        )

        guard !conditions.isUnconstrained else {
            throw NaturalLanguageSearchError.noConditions
        }
        return conditions
    }

    static func nonEmptyText(_ text: String?) -> String? {
        guard let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmedText.isEmpty else {
            return nil
        }
        return trimmedText
    }
}

private extension NaturalLanguageSearchValidator {
    static func asksToChangeData(_ request: String) -> Bool {
        contains(
            words: mutationWords,
            phrases: mutationPhrases,
            in: request
        )
    }

    static func asksToCalculate(_ request: String) -> Bool {
        contains(
            words: calculationWords,
            phrases: calculationPhrases,
            in: request
        )
    }

    static func contains(
        words: Set<String>,
        phrases: [String],
        in request: String
    ) -> Bool {
        let lowercasedRequest = request.lowercased()
        let requestWords = lowercasedRequest
            .components(separatedBy: CharacterSet.letters.inverted)
        if requestWords.contains(where: words.contains) {
            return true
        }
        return phrases.contains { phrase in
            lowercasedRequest.contains(phrase)
        }
    }

    static func period(
        from extraction: NaturalLanguageSearchExtraction,
        currentDate: Date,
        calendar: Calendar,
        grounding: inout NaturalLanguageSearchGrounding
    ) throws -> ItemSearchPeriod? {
        let current = currentYearMonth(
            of: currentDate,
            calendar: calendar
        )
        let relativePeriod: ItemSearchPeriod?
        if let offset = extraction.relativeMonthOffset {
            relativePeriod = try period(
                offset: offset,
                from: current
            )
        } else {
            relativePeriod = nil
        }
        let explicitPeriod = try period(
            year: extraction.year,
            month: extraction.month,
            currentYear: current.year
        )

        let period: ItemSearchPeriod?
        switch (relativePeriod, explicitPeriod) {
        case (nil, nil):
            period = nil
        case let (relativePeriod?, nil):
            period = relativePeriod
        case let (nil, explicitPeriod?):
            period = explicitPeriod
        case let (relativePeriod?, explicitPeriod?):
            guard relativePeriod == explicitPeriod else {
                throw NaturalLanguageSearchError.contradictoryMonth
            }
            period = relativePeriod
        }
        try grounding.useMonth(
            relativeOffset: extraction.relativeMonthOffset,
            year: extraction.year,
            month: extraction.month
        )
        return period
    }

    static func currentYearMonth(
        of date: Date,
        calendar: Calendar
    ) -> (year: Int, month: Int) {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let components = gregorian.dateComponents([.year, .month], from: date)
        return (components.year ?? .zero, components.month ?? 1)
    }

    static func period(
        offset: Int,
        from current: (year: Int, month: Int)
    ) throws -> ItemSearchPeriod {
        guard supportedRelativeMonthOffsets.contains(offset) else {
            throw NaturalLanguageSearchError.invalidMonth
        }
        let monthIndex = current.year * monthsPerYear + (current.month - 1) + offset
        guard let period = ItemSearchPeriod(
            year: monthIndex / monthsPerYear,
            month: monthIndex % monthsPerYear + 1
        ) else {
            throw NaturalLanguageSearchError.invalidMonth
        }
        return period
    }

    static func period(
        year: Int?,
        month: Int?,
        currentYear: Int
    ) throws -> ItemSearchPeriod? {
        guard let month else {
            guard year == nil else {
                throw NaturalLanguageSearchError.missingMonth
            }
            return nil
        }
        guard let period = ItemSearchPeriod(
            year: year ?? currentYear,
            month: month
        ) else {
            throw NaturalLanguageSearchError.invalidMonth
        }
        return period
    }

    static func content(
        _ content: String?,
        request: String
    ) throws -> String? {
        guard let content = nonEmptyText(content) else {
            return nil
        }
        guard request.range(of: content, options: groundingOptions) != nil else {
            throw NaturalLanguageSearchError.ungroundedContent
        }
        return content
    }
}

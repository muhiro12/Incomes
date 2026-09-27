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
    private static let amountLocale = Locale(identifier: "en_US")
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
        return trimmedRequest
    }

    static func conditions(
        from extraction: NaturalLanguageSearchExtraction,
        request: String,
        currentDate: Date,
        calendar: Calendar
    ) throws -> ItemSearchConditions {
        let validRequest = try validatedRequest(request)

        guard extraction.intent == .search else {
            throw NaturalLanguageSearchError.unsupportedRequest
        }

        let unsupportedTerms = extraction.unsupportedTerms.compactMap(nonEmptyText)
        guard unsupportedTerms.isEmpty else {
            throw NaturalLanguageSearchError.unsupportedTerms(unsupportedTerms)
        }

        let conditions = ItemSearchConditions(
            period: try period(
                from: extraction,
                currentDate: currentDate,
                calendar: calendar
            ),
            content: try content(
                extraction.content,
                request: validRequest
            ),
            income: try amountRange(
                extraction.income,
                target: .income
            ),
            outgo: try amountRange(
                extraction.outgo,
                target: .outgo
            )
        )

        guard !conditions.isUnconstrained else {
            throw NaturalLanguageSearchError.noConditions
        }
        return conditions
    }
}

private extension NaturalLanguageSearchValidator {
    static func asksToChangeData(_ request: String) -> Bool {
        let words = request
            .lowercased()
            .components(separatedBy: CharacterSet.letters.inverted)
        if words.contains(where: mutationWords.contains) {
            return true
        }
        return mutationPhrases.contains { phrase in
            request.contains(phrase)
        }
    }

    static func nonEmptyText(_ text: String?) -> String? {
        guard let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmedText.isEmpty else {
            return nil
        }
        return trimmedText
    }

    static func period(
        from extraction: NaturalLanguageSearchExtraction,
        currentDate: Date,
        calendar: Calendar
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

        switch (relativePeriod, explicitPeriod) {
        case (nil, nil):
            return nil
        case let (period?, nil),
             let (nil, period?):
            return period
        case let (relativePeriod?, explicitPeriod?):
            guard relativePeriod == explicitPeriod else {
                throw NaturalLanguageSearchError.contradictoryMonth
            }
            return relativePeriod
        }
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

    static func amountRange(
        _ bounds: NaturalLanguageSearchExtraction.AmountBounds?,
        target: NaturalLanguageSearchError.AmountTarget
    ) throws -> ItemSearchAmountRange? {
        guard let bounds else {
            return nil
        }
        let minimumText = nonEmptyText(bounds.minimum)
        let maximumText = nonEmptyText(bounds.maximum)
        guard minimumText != nil || maximumText != nil else {
            throw NaturalLanguageSearchError.missingAmount(target)
        }
        guard bounds.minimum == nil || minimumText != nil,
              bounds.maximum == nil || maximumText != nil else {
            throw NaturalLanguageSearchError.invalidAmount(target)
        }
        let minimum = try minimumText.map { text in
            try amount(text, target: target)
        }
        let maximum = try maximumText.map { text in
            try amount(text, target: target)
        }
        guard let range = ItemSearchAmountRange(
            minimum: minimum,
            maximum: maximum
        ) else {
            throw NaturalLanguageSearchError.invertedRange(target)
        }
        return range
    }

    static func amount(
        _ text: String,
        target: NaturalLanguageSearchError.AmountTarget
    ) throws -> Decimal {
        guard let value = DecimalTextParser.parse(text, locale: amountLocale) else {
            throw NaturalLanguageSearchError.invalidAmount(target)
        }
        return value
    }
}

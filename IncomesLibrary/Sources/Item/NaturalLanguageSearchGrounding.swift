import Foundation

/// Numbers, month names, and relative month words written in a
/// natural-language search request.
///
/// Validation uses this to require that extracted years, months, and amounts
/// come from the request, and that every written number or month is used by
/// some condition instead of being silently dropped.
struct NaturalLanguageSearchGrounding {
    /// What a written number can represent, judged from the text after it.
    enum NumberRole: Equatable {
        /// A plain number, such as an amount or a year or month in a numeric date.
        case plain
        /// A number followed by a year unit, such as 年.
        case year
        /// A number followed by a month unit, such as 月.
        case month
        /// A number no supported condition represents, such as a day, a
        /// percentage, a duration, or a scaled amount like 30万.
        case unsupported
    }

    /// One number written in the request.
    struct Number: Equatable {
        let text: String
        let value: Decimal?
        let role: NumberRole
        var isUsed = false
    }

    private static let numberPattern = #"(?<![0-9.])-?(?:[0-9]{1,3}(?:,[0-9]{3})+|[0-9]+)(?:\.[0-9]+)?(?![0-9])"#
    private static let posixLocale = Locale(identifier: "en_US_POSIX")
    private static let monthNameLocales = ["en_US", "es_ES", "fr_FR"]
    private static let yearUnits = ["年"]
    private static let monthUnits = ["月"]
    private static let unsupportedUnits = [
        "か月", "ヶ月", "ヵ月", "カ月", "ケ月", "日", "時", "分", "秒", "週",
        "%", "万", "千", "億", "百", "割", "件", "回", "個", "歳"
    ]
    private static let unsupportedWords: Set<String> = [
        "k", "m", "b", "bn", "thousand", "thousands", "million", "millions",
        "billion", "percent", "st", "nd", "rd", "th"
    ]
    private static let monthAfterNextOffset = 2
    // Longer phrases come first so that 再来月 is not also read as 来月.
    private static let relativeMonthPhrases: [(phrase: String, offset: Int)] = [
        ("再来月", monthAfterNextOffset),
        ("先々月", -monthAfterNextOffset),
        ("先先月", -monthAfterNextOffset),
        ("this month", 0),
        ("今月", 0),
        ("这个月", 0),
        ("本月", 0),
        ("ce mois", 0),
        ("este mes", 0),
        ("next month", 1),
        ("来月", 1),
        ("下个月", 1),
        ("mois prochain", 1),
        ("proximo mes", 1),
        ("last month", -1),
        ("先月", -1),
        ("上个月", -1),
        ("mois dernier", -1),
        ("mes pasado", -1)
    ]
    private static let foldingOptions: String.CompareOptions = [
        .caseInsensitive,
        .diacriticInsensitive,
        .widthInsensitive
    ]

    private(set) var numbers: [Number]
    /// Month numbers named by words such as "March" in the request.
    let namedMonths: Set<Int>
    /// Month offsets stated by relative words such as "next month" in the request.
    let relativeMonthOffsets: Set<Int>

    /// Texts of written numbers that no condition used.
    var unusedNumberTexts: [String] {
        numbers.filter { number in
            !number.isUsed
        }
        .map(\.text)
    }

    init(request: String) {
        let text = Self.normalized(request)
        numbers = Self.numbers(in: text)
        namedMonths = Self.namedMonths(in: text)
        relativeMonthOffsets = Self.relativeMonthOffsets(in: text)
    }

    /// Checks an extracted month against the request and marks its numbers as used.
    ///
    /// A relative offset must match the one relative month word in the request.
    /// An explicit month must match a written month name or number, and a year
    /// must be written. A month the request states but the extraction omits
    /// also fails, so the search never silently covers every month.
    mutating func useMonth(
        relativeOffset: Int?,
        year: Int?,
        month: Int?
    ) throws {
        if let relativeOffset {
            guard relativeMonthOffsets == [relativeOffset] else {
                throw NaturalLanguageSearchError.ungroundedMonth
            }
        } else if !relativeMonthOffsets.isEmpty {
            throw NaturalLanguageSearchError.unusedMonth
        }
        if let year {
            guard use(Decimal(year), roles: [.plain, .year]) else {
                throw NaturalLanguageSearchError.ungroundedMonth
            }
        }
        guard let month else {
            guard namedMonths.isEmpty else {
                throw NaturalLanguageSearchError.unusedMonth
            }
            return
        }
        if namedMonths.isEmpty {
            guard use(Decimal(month), roles: [.plain, .month]) else {
                throw NaturalLanguageSearchError.ungroundedMonth
            }
        } else if namedMonths != [month] {
            throw NaturalLanguageSearchError.unusedMonth
        }
    }

    /// Marks a written plain amount as used; returns false when the request does not write it.
    mutating func useAmount(_ amount: Decimal) -> Bool {
        use(amount, roles: [.plain])
    }

    /// Marks numbers that are part of literal content text as used.
    ///
    /// Returns false when the content repeats a number another condition
    /// already uses, such as an amount phrase copied into the item name.
    mutating func useNumbers(inContent content: String) -> Bool {
        Self.numbers(in: Self.normalized(content)).allSatisfy { number in
            guard let value = number.value else {
                return false
            }
            return use(value, roles: [.plain, .year, .month, .unsupported])
        }
    }
}

private extension NaturalLanguageSearchGrounding {
    static var monthNames: [String: Int] {
        var names: [String: Int] = [:]
        for identifier in monthNameLocales {
            let formatter = DateFormatter()
            formatter.locale = .init(identifier: identifier)
            let symbolSets = [
                formatter.monthSymbols,
                formatter.standaloneMonthSymbols,
                identifier == "en_US" ? formatter.shortMonthSymbols : nil
            ]
            for symbols in symbolSets.compactMap(\.self) {
                for (index, symbol) in symbols.enumerated() {
                    let name = symbol
                        .folding(options: foldingOptions, locale: posixLocale)
                        .trimmingCharacters(in: .punctuationCharacters)
                    names[name] = index + 1
                }
            }
        }
        return names
    }

    static func normalized(_ text: String) -> String {
        let halfwidth = text.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? text
        return halfwidth.replacingOccurrences(of: "\u{2212}", with: "-")
    }

    static func numbers(in text: String) -> [Number] {
        guard let expression = try? NSRegularExpression(pattern: numberPattern) else {
            assertionFailure()
            return []
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return expression.matches(in: text, range: range).compactMap { match in
            guard let matchRange = Range(match.range, in: text) else {
                return nil
            }
            let numberText = String(text[matchRange])
            let value = DecimalTextParser.parse(numberText, locale: Locale(identifier: "en_US"))
            return .init(
                text: numberText,
                value: value,
                role: role(following: text[matchRange.upperBound...])
            )
        }
    }

    static func role(following text: Substring) -> NumberRole {
        let rest = text.drop { character in
            character == " "
        }
        if unsupportedUnits.contains(where: rest.hasPrefix) {
            return .unsupported
        }
        if yearUnits.contains(where: rest.hasPrefix) {
            return .year
        }
        if monthUnits.contains(where: rest.hasPrefix) {
            return .month
        }
        let word = rest.prefix(while: \.isLetter)
        if unsupportedWords.contains(word.lowercased()) {
            return .unsupported
        }
        return .plain
    }

    static func namedMonths(in text: String) -> Set<Int> {
        let words = Set(
            text.folding(options: foldingOptions, locale: posixLocale)
                .components(separatedBy: CharacterSet.letters.inverted)
                .filter { word in
                    !word.isEmpty
                }
        )
        return Set(monthNames.compactMap { name, month in
            words.contains(name) ? month : nil
        })
    }

    static func relativeMonthOffsets(in text: String) -> Set<Int> {
        var remainingText = text.folding(options: foldingOptions, locale: posixLocale)
        var offsets: Set<Int> = []
        for (phrase, offset) in relativeMonthPhrases where remainingText.contains(phrase) {
            offsets.insert(offset)
            remainingText = remainingText.replacingOccurrences(of: phrase, with: " ")
        }
        return offsets
    }

    mutating func use(_ value: Decimal, roles: Set<NumberRole>) -> Bool {
        guard let index = numbers.firstIndex(where: { number in
            !number.isUsed && roles.contains(number.role) && number.value == value
        }) else {
            return false
        }
        numbers[index].isUsed = true
        return true
    }
}

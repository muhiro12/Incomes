import Foundation

/// Reads a complete source number without passing through a generated floating-point value.
public enum ItemInferenceAmountOperations {
    private static let maximumExpressionLength = 80

    /// Returns nil for an absent expression and requires one exact source-backed numeric value.
    @available(iOS 26.0, *)
    public static func amount(expression: String, sourceText: String, locale: Locale) throws -> Decimal? {
        let expression = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !expression.isEmpty else {
            return nil
        }
        guard expression.count <= maximumExpressionLength else {
            throw ItemInferenceError.invalidResult
        }
        let numberExpression = numberExpression(expression, sourceText: sourceText, locale: locale)
        let candidates = [locale, Locale(identifier: "en_US_POSIX")].compactMap { locale in
            DecimalTextParser.parse(numberExpression, locale: locale)
        }
        guard candidates.contains(where: { $0 >= .zero }) else {
            throw ItemInferenceError.invalidResult
        }
        // The source owns decimal placement. A model sometimes drops every
        // separator; recover only a unique complete digit sequence, never a prefix.
        let matches = Set(sourceNumbers(sourceText).compactMap { number -> Decimal? in
            guard let amount = DecimalTextParser.parse(number, locale: locale), amount >= .zero else {
                return nil
            }
            let preservesDigits = numberExpression.allSatisfy(\.isNumber) && !number.lowercased().contains("e")
                && digits(in: number) == digits(in: numberExpression)
            return candidates.contains(amount) || preservesDigits ? amount : nil
        })
        guard matches.count == 1, let amount = matches.first else {
            throw ItemInferenceError.invalidResult
        }
        return amount
    }
}

private extension ItemInferenceAmountOperations {
    static func numberExpression(_ expression: String, sourceText: String, locale: Locale) -> String {
        let numbers = sourceNumbers(expression)
        guard sourceText.contains(expression), numbers.count == 1,
              let number = numbers.first, let range = expression.range(of: number) else {
            return expression
        }
        let currency = expression.replacingCharacters(in: range, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let currencies = Locale.commonISOCurrencyCodes
            + ["$", "€", "£", "¥", "￥", "円", "元", locale.currencySymbol ?? ""]
        return currencies.contains(currency) ? number : expression
    }

    static func digits(in text: String) -> [Int] {
        text.compactMap(\.wholeNumberValue)
    }

    static func sourceNumbers(_ sourceText: String) -> [String] {
        let pattern = #"[+−-]?\p{Nd}+(?:[.,，．'’\u00A0\u202F\u2009 ]\p{Nd}+)*(?:[eE][+-]?\p{Nd}+)?"#
        guard let regularExpression = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        return regularExpression.matches(
            in: sourceText,
            range: NSRange(sourceText.startIndex..., in: sourceText)
        )
        .compactMap { match in
            guard let range = Range(match.range, in: sourceText) else {
                return nil
            }
            // A bare digit from a scaled amount must not turn 3万円 into 3.
            if range.upperBound < sourceText.endIndex,
               "十百千万億兆".contains(sourceText[range.upperBound]) {
                return nil
            }
            return String(sourceText[range])
        }
    }
}

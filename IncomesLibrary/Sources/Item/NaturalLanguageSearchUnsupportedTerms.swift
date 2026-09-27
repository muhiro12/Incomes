import Foundation

/// Rejects explicitly unsupported concepts before generation can omit them.
/// This conservative vocabulary is not a complete semantic parser.
enum NaturalLanguageSearchUnsupportedTerms {
    private static let words: Set<String> = [
        "category", "categories", "tag", "tags", "balance", "balances",
        "subscription", "subscriptions", "expensive", "cheap",
        "sort", "sorted", "cheapest", "largest", "smallest"
    ]
    private static let phrases = [
        "カテゴリ", "カテゴリー", "タグ", "残高", "サブスク",
        "高い", "安い", "並べ", "未満", "より多い", "より少ない",
        "more than", "less than"
    ]

    static func find(in request: String) -> [String] {
        let normalized = request.folding(
            options: [.caseInsensitive, .widthInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        )
        let requestWords = Set(normalized.components(separatedBy: CharacterSet.letters.inverted))
        let matchedWords = words.intersection(requestWords)
        let matchedPhrases = phrases.filter { normalized.contains($0) }
        return Set(matchedWords).union(matchedPhrases).sorted()
    }
}

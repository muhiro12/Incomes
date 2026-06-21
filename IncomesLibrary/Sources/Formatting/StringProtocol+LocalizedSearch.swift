import Foundation

extension StringProtocol {
    /// Returns true when both strings match after full-width and Hiragana normalization.
    func normalizedContains<T>(_ other: T) -> Bool where T: StringProtocol {
        let normalizedSelf = self
            .applyingTransform(.fullwidthToHalfwidth, reverse: false)?
            .applyingTransform(.hiraganaToKatakana, reverse: false) ?? ""

        let normalizedOther = other
            .applyingTransform(.fullwidthToHalfwidth, reverse: false)?
            .applyingTransform(.hiraganaToKatakana, reverse: false) ?? ""

        return normalizedSelf.localizedStandardContains(normalizedOther)
    }
}

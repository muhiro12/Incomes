import UIKit

enum IncomesPasteboardWriter {
    static func copy(
        _ text: String
    ) {
        UIPasteboard.general.string = text
        Haptic.success.impact()
    }

    static func copy(
        _ url: URL
    ) {
        copy(url.absoluteString)
    }
}

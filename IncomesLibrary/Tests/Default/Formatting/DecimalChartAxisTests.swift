import Foundation
@testable import IncomesLibrary
import Testing

struct DecimalChartAxisTests {
    @Test
    func chart_axis_amount_uses_japanese_compact_units() {
        let style: Decimal.FormatStyle = .chartAxisAmount(locale: Locale(identifier: "ja_JP"))

        #expect(style.format(.zero) == "0")
        #expect(style.format(500_000) == "50万")
        #expect(style.format(-500_000) == "-50万")
        #expect(style.format(1_000_000) == "100万")
        #expect(style.format(-1_000_000) == "-100万")
        #expect(style.format(12_500_000) == "1250万")
    }

    @Test
    func chart_axis_amount_uses_english_compact_units() {
        let style: Decimal.FormatStyle = .chartAxisAmount(locale: Locale(identifier: "en_US"))

        #expect(style.format(.zero) == "0")
        #expect(style.format(500_000) == "500K")
        #expect(style.format(-500_000) == "-500K")
        #expect(style.format(1_000_000) == "1M")
        #expect(style.format(-1_000_000) == "-1M")
        #expect(style.format(1_250_000) == "1.25M")
    }

    @Test(arguments: ["ja_JP", "en_US", "de_DE", "fr_FR", "zh_Hans_CN"])
    func chart_axis_amount_never_uses_exponent_notation(localeIdentifier: String) {
        let style: Decimal.FormatStyle = .chartAxisAmount(locale: Locale(identifier: localeIdentifier))
        let values: [Decimal] = [
            500_000,
            -500_000,
            1_000_000,
            -1_000_000,
            1_234_567,
            100_000_000_000
        ]

        for value in values {
            let text = style.format(value)
            #expect(!text.contains("E"), "\(localeIdentifier): \(text)")
            #expect(!text.contains("e+"), "\(localeIdentifier): \(text)")
        }
    }
}

//
//  LocaleAmountConverterTest.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2025/04/22.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import Incomes
import Testing

struct LocaleAmountConverterTest {
    @Test func testDefaultFallback() {
        let locale = Locale(identifier: "en_US")
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 50, locale: locale) == 50)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 100, locale: locale) == 100)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 200, locale: locale) == 200)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 500, locale: locale) == 500)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 1_000, locale: locale) == 1_000)
    }

    @Test func testESConversion() {
        let locale = Locale(identifier: "es_ES")
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 50, locale: locale) == 50)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 100, locale: locale) == 100)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 200, locale: locale) == 200)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 500, locale: locale) == 500)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 1_000, locale: locale) == 1_000)
    }

    @Test func testEURConversion() {
        let locale = Locale(identifier: "fr_FR")
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 50, locale: locale) == 50)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 100, locale: locale) == 100)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 200, locale: locale) == 200)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 500, locale: locale) == 500)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 1_000, locale: locale) == 1_000)
    }

    @Test func testCNYConversion() {
        let locale = Locale(identifier: "zh_CN")
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 50, locale: locale) == 1_000)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 100, locale: locale) == 2_000)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 200, locale: locale) == 4_000)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 500, locale: locale) == 10_000)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 1_000, locale: locale) == 20_000)
    }

    @Test func testJPYConversion() {
        let locale = Locale(identifier: "ja_JP")
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 50, locale: locale) == 5_000)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 100, locale: locale) == 10_000)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 200, locale: locale) == 20_000)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 500, locale: locale) == 50_000)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 1_000, locale: locale) == 100_000)
    }

    @Test func testUnsupportedConversion() {
        let locale = Locale(identifier: "ko_KR")
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 50, locale: locale) == 50)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 100, locale: locale) == 100)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 200, locale: locale) == 200)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 500, locale: locale) == 500)
        #expect(LocaleAmountConverter.localizedAmount(baseUSD: 1_000, locale: locale) == 1_000)
    }
}

//
//  DateExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import Incomes
import Testing

@Suite(.serialized)
struct DateExtensionTests {
    init() {
        NSTimeZone.default = .current
    }

    // MARK: - Default Locale (parameterized by timeZones)

    @Suite
    struct DefaultLocaleTests {
        @Test("yyyy is as expected", arguments: timeZones)
        func yyyy_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        @Test("yyyy at 12:00 is as expected", arguments: timeZones)
        func yyyy_at_noon_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T12:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        @Test("yyyy at 15:00 is as expected", arguments: timeZones)
        func yyyy_at_15_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        @Test("yyyy at 21:00 is as expected", arguments: timeZones)
        func yyyy_at_21_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T21:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        @Test("yyyy at Dec 31 is as expected", arguments: timeZones)
        func yyyy_at_dec31_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-12-31T00:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        @Test("yyyy at 12:00 on Dec 31 is as expected", arguments: timeZones)
        func yyyy_at_noon_dec31_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-12-31T12:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        @Test("yyyy at 15:00 on Dec 31 is as expected", arguments: timeZones)
        func yyyy_at_15_dec31_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-12-31T15:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        @Test("yyyy at 21:00 on Dec 31 is as expected", arguments: timeZones)
        func yyyy_at_21_dec31_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-12-31T21:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        @Test("yyyyMMM is as expected", arguments: timeZones)
        func yyyyMMM_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMM)
            #expect(result == "Jan 2000")
        }

        @Test("yyyyMMM at 15:00 is as expected", arguments: timeZones)
        func yyyyMMM_at_15_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMM)
            #expect(result == "Jan 2000")
        }

        @Test("MMMd is as expected", arguments: timeZones)
        func MMMd_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.MMMd)
            #expect(result == "Jan 1")
        }

        @Test("MMMd at 15:00 is as expected", arguments: timeZones)
        func MMMd_at_15_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.MMMd)
            #expect(result == "Jan 1")
        }

        @Test("yyyyMMMd is as expected", arguments: timeZones)
        func yyyyMMMd_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Jan 1, 2000")
        }

        @Test("yyyyMMMd at 12:00 is as expected", arguments: timeZones)
        func yyyyMMMd_at_noon_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T12:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Jan 1, 2000")
        }

        @Test("yyyyMMMd at 15:00 is as expected", arguments: timeZones)
        func yyyyMMMd_at_15_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Jan 1, 2000")
        }

        @Test("yyyyMMMd at 21:00 is as expected", arguments: timeZones)
        func yyyyMMMd_at_21_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-01-01T21:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Jan 1, 2000")
        }

        @Test("yyyyMMMd at Dec 31 is as expected", arguments: timeZones)
        func yyyyMMMd_dec31_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-12-31T00:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Dec 31, 2000")
        }

        @Test("yyyyMMMd at 12:00 on Dec 31 is as expected", arguments: timeZones)
        func yyyyMMMd_noon_dec31_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-12-31T12:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Dec 31, 2000")
        }

        @Test("yyyyMMMd at 15:00 on Dec 31 is as expected", arguments: timeZones)
        func yyyyMMMd_15_dec31_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-12-31T15:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Dec 31, 2000")
        }

        @Test("yyyyMMMd at 21:00 on Dec 31 is as expected", arguments: timeZones)
        func yyyyMMMd_21_dec31_is_expected(_ timeZone: TimeZone) {
            NSTimeZone.default = timeZone

            let result = shiftedDate("2000-12-31T21:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Dec 31, 2000")
        }
    }

    // MARK: - En Locale

    @Suite
    struct EnLocaleTests {
        @Test("yyyy in en is as expected")
        func yyyy_en_is_expected() {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyy, locale: .init(identifier: "en_US"))
            #expect(result == "2000")
        }

        @Test("yyyy at 15:00 in en is as expected")
        func yyyy_at_15_en_is_expected() {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyy, locale: .init(identifier: "en_US"))
            #expect(result == "2000")
        }

        @Test("yyyyMMM in en is as expected")
        func yyyyMMM_en_is_expected() {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 2000")
        }

        @Test("yyyyMMM at 15:00 in en is as expected")
        func yyyyMMM_at_15_en_is_expected() {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 2000")
        }

        @Test("MMMd in en is as expected")
        func MMMd_en_is_expected() {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.MMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1")
        }

        @Test("MMMd at 15:00 in en is as expected")
        func MMMd_at_15_en_is_expected() {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.MMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1")
        }

        @Test("yyyyMMMd in en is as expected")
        func yyyyMMMd_en_is_expected() {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1, 2000")
        }

        @Test("yyyyMMMd at 12:00 in en is as expected")
        func yyyyMMMd_at_noon_en_is_expected() {
            let result = shiftedDate("2000-01-01T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1, 2000")
        }

        @Test("yyyyMMMd at 15:00 in en is as expected")
        func yyyyMMMd_at_15_en_is_expected() {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1, 2000")
        }

        @Test("yyyyMMMd at 21:00 in en is as expected")
        func yyyyMMMd_at_21_en_is_expected() {
            let result = shiftedDate("2000-01-01T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1, 2000")
        }

        @Test("yyyyMMMd at 12-31 in en is as expected")
        func yyyyMMMd_dec31_en_is_expected() {
            let result = shiftedDate("2000-12-31T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Dec 31, 2000")
        }

        @Test("yyyyMMMd at 12:00, 12-31 in en is as expected")
        func yyyyMMMd_noon_dec31_en_is_expected() {
            let result = shiftedDate("2000-12-31T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Dec 31, 2000")
        }

        @Test("yyyyMMMd at 15:00, 12-31 in en is as expected")
        func yyyyMMMd_15_dec31_en_is_expected() {
            let result = shiftedDate("2000-12-31T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Dec 31, 2000")
        }

        @Test("yyyyMMMd at 21:00, 12-31 in en is as expected")
        func yyyyMMMd_21_dec31_en_is_expected() {
            let result = shiftedDate("2000-12-31T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Dec 31, 2000")
        }
    }

    // MARK: - Ja Locale

    @Suite
    struct JaLocaleTests {
        @Test("yyyy in ja is as expected")
        func yyyy_ja_is_expected() {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyy, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年")
        }

        @Test("yyyy at 15:00 in ja is as expected")
        func yyyy_at_15_ja_is_expected() {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyy, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年")
        }

        @Test("yyyyMMM in ja is as expected")
        func yyyyMMM_ja_is_expected() {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月")
        }

        @Test("yyyyMMM at 15:00 in ja is as expected")
        func yyyyMMM_at_15_ja_is_expected() {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月")
        }

        @Test("MMMd in ja is as expected")
        func MMMd_ja_is_expected() {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.MMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "1月1日")
        }

        @Test("MMMd at 15:00 in ja is as expected")
        func MMMd_at_15_ja_is_expected() {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.MMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "1月1日")
        }

        @Test("yyyyMMMd in ja is as expected")
        func yyyyMMMd_ja_is_expected() {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        @Test("yyyyMMMd at 15:00 in ja is as expected")
        func yyyyMMMd_at_15_ja_is_expected() {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        @Test("yyyyMMMd at 00:00 in ja is as expected")
        func yyyyMMMd_midnight_ja_is_expected() {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        @Test("yyyyMMMd at 12:00 in ja is as expected")
        func yyyyMMMd_noon_ja_is_expected() {
            let result = shiftedDate("2000-01-01T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        @Test("yyyyMMMd at 21:00 in ja is as expected")
        func yyyyMMMd_21_ja_is_expected() {
            let result = shiftedDate("2000-01-01T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        @Test("yyyyMMMd at 12-31 in ja is as expected")
        func yyyyMMMd_dec31_ja_is_expected() {
            let result = shiftedDate("2000-12-31T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年12月31日")
        }

        @Test("yyyyMMMd at 12:00, 12-31 in ja is as expected")
        func yyyyMMMd_noon_dec31_ja_is_expected() {
            let result = shiftedDate("2000-12-31T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年12月31日")
        }

        @Test("yyyyMMMd at 15:00, 12-31 in ja is as expected")
        func yyyyMMMd_15_dec31_ja_is_expected() {
            let result = shiftedDate("2000-12-31T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年12月31日")
        }

        @Test("yyyyMMMd at 21:00, 12-31 in ja is as expected")
        func yyyyMMMd_21_dec31_ja_is_expected() {
            let result = shiftedDate("2000-12-31T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年12月31日")
        }
    }
}

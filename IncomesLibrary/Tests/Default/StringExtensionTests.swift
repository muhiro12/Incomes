//
//  StringExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

@testable import Incomes
import Testing

struct StringExtensionTests {
    struct IsNotEmptyTests {
        @Test("Text returns true")
        func text_returns_true() {
            let string = "text"
            #expect(string.isNotEmpty)
        }

        @Test("Empty returns false")
        func empty_returns_false() {
            let string = ""
            #expect(!string.isNotEmpty)
        }
    }

    struct IsEmptyOrDecimalTests {
        @Test("Empty returns true")
        func empty_returns_true() {
            let string = ""
            #expect(string.isEmptyOrDecimal)
        }

        @Test("0 returns true")
        func zero_returns_true() {
            let string = "0"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Int returns true")
        func int_returns_true() {
            let string = "1000"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Text returns false")
        func text_returns_false() {
            let string = "text"
            #expect(!string.isEmptyOrDecimal)
        }

        @Test("Int starting with 0 returns true")
        func leading_zero_returns_true() {
            let string = "01000"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Int starting with minus returns true")
        func negative_int_returns_true() {
            let string = "-1000"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Int starting with minus and 0 returns true")
        func negative_leading_zero_returns_true() {
            let string = "-01000"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Double returns true")
        func double_returns_true() {
            let string = "1.000"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Int with comma returns true")
        func int_with_comma_returns_true() {
            let string = "1,000"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Int32 upper limit returns true")
        func int32_upper_limit_returns_true() {
            let string = "2147483647"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Numbers overing Int32 upper limit returns true")
        func over_int32_upper_returns_true() {
            let string = "2147483648"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Int32 lower limit returns true")
        func int32_lower_limit_returns_true() {
            let string = "-2147483648"
            #expect(string.isEmptyOrDecimal)
        }

        @Test("Numbers overing Int lower limit returns true")
        func over_int_lower_returns_true() {
            let string = "-2147483649"
            #expect(string.isEmptyOrDecimal)
        }
    }

    struct DecimalValueTests {
        @Test("Text returns 0")
        func text_returns_zero() {
            let string = "text"
            #expect(string.decimalValue == 0)
        }

        @Test("0 returns 0")
        func zero_returns_zero() {
            let string = "0"
            #expect(string.decimalValue == 0)
        }

        @Test("Int returns decimal")
        func int_returns_decimal() {
            let string = "1000"
            #expect(string.decimalValue == 1_000)
        }
    }
}

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
    @Test
    func testIsNotEmpty() {
        do {
            let string = "text"
            #expect(string.isNotEmpty)
        }

        do {
            let string = ""
            #expect(!string.isNotEmpty)
        }
    }

    @Test
    func testIsEmptyOrDecimal() {
        do {
            let string = ""
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "0"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "1000"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "text"
            #expect(!string.isEmptyOrDecimal)
        }

        do {
            let string = "01000"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "-1000"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "-01000"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "1.000"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "1,000"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "2147483647"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "2147483648"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "-2147483648"
            #expect(string.isEmptyOrDecimal)
        }

        do {
            let string = "-2147483649"
            #expect(string.isEmptyOrDecimal)
        }
    }

    @Test
    func testDecimalValue() {
        do {
            let string = "text"
            #expect(string.decimalValue == 0)
        }

        do {
            let string = "0"
            #expect(string.decimalValue == 0)
        }

        do {
            let string = "1000"
            #expect(string.decimalValue == 1_000)
        }
    }
}

//
//  TagDisplayNameTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagDisplayNameTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func displayName_returns_name_for_year_tag() throws {
        let tag = try Tag.create(context: context, name: "2024", type: .year)
        #expect(tag.displayName == "2024")
    }

    @Test
    func displayName_converts_year_month_tag_to_readable_format() throws {
        let tag = try Tag.create(context: context, name: "202401", type: .yearMonth)
        if tag.displayName == tag.name {
            let parsedDate = tag.name.stableDateValueWithoutLocale(.yyyyMM)
            print("TagDisplayNameTests diagnostics: name=\(tag.name) displayName=\(tag.displayName)")
            print("  parsedDate=\(String(describing: parsedDate))")
            print("  locale=\(Locale.current.identifier) timeZone=\(TimeZone.current.identifier)")
            print("  calendar=\(Calendar.current.identifier) calendarTimeZone=\(Calendar.current.timeZone.identifier)")
        }
        #expect(tag.displayName != tag.name)
    }

    @Test
    func displayName_returns_others_for_empty_category() throws {
        let tag = try Tag.create(context: context, name: "", type: .category)
        #expect(tag.displayName == "Others")
    }

    @Test
    func displayName_returns_name_for_content_tag() throws {
        let tag = try Tag.create(context: context, name: "Groceries", type: .content)
        #expect(tag.displayName == "Groceries")
    }
}

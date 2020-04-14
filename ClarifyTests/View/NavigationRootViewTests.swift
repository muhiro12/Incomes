//
//  NavigationRootViewTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class NavigationRootViewTests: XCTestCase {
    func testTestData() {
        let listItem = ListItem(id: UUID(),
                                date: Date(),
                                content: "Content",
                                income: 999999,
                                expenditure: 99999,
                                balance: 9999999)
        XCTAssertNoThrow(NavigationRootView_Previews.testData(listItem))
    }

    func testPreviews() {
        XCTAssertNoThrow(NavigationRootView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(NavigationRootView_Previews.previews.body)
    }
}

//
//  TabRootViewTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class TabRootViewTests: XCTestCase {
    func testPreviews() {
        XCTAssertNoThrow(TabRootView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(TabRootView_Previews.previews.body)
    }
}
//
//  ListItemNarrowViewTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class ListItemNarrowViewTests: XCTestCase {
    func testPreviews() {
        XCTAssertNoThrow(ListItemNarrowView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(ListItemNarrowView_Previews.previews.body)
    }
}

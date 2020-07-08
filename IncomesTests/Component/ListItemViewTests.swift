//
//  ListItemViewTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes_Dev

class ListItemViewTests: XCTestCase {
    func testPreviews() {
        XCTAssertNoThrow(ListItemView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(ListItemView_Previews.previews.body)
    }
}

//
//  GroupViewTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class GroupViewTests: XCTestCase {
    func testPreviews() {
        XCTAssertNoThrow(GroupView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(GroupView_Previews.previews.body)
    }
}

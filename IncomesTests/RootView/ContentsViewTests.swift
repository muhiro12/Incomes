//
//  ContentsViewTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class ContentsViewTests: XCTestCase {
    func testPreviews() {
        XCTAssertNoThrow(ContentsView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(ContentsView_Previews.previews.body)
    }
}

//
//  ListItemWideViewTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class ListItemWideViewTests: XCTestCase {
    func testPreviews() {
        XCTAssertNoThrow(ListItemWideView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(ListItemWideView_Previews.previews.body)
    }
}

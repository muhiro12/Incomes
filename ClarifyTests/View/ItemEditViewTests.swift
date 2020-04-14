//
//  ItemEditViewTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class ItemEditViewTests: XCTestCase {
    func testPreviews() {
        XCTAssertNoThrow(ItemEditView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(ItemEditView_Previews.previews.body)
    }
}
